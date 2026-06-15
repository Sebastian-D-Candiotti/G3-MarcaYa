# frozen_string_literal: true

require "test_helper"
require_relative "../../../app/domain/errors"
require_relative "../../../app/domain/value_objects/notificacion_push"
require_relative "../../../app/infrastructure/services/fcm_sender"

class Infrastructure::Services::FcmSenderTest < ActiveSupport::TestCase
  def setup
    @sender = Infrastructure::Services::FcmSender.new
    @notificacion = Domain::ValueObjects::NotificacionPush.new(
      title: "Asistencia marcada",
      body: "Entrada — 08:32 hs | Ubicación válida",
      data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
    )
    @fcm_token = "fcm_device_token_123"
    @original_server_key = ENV["FCM_SERVER_KEY"]
    @original_start = Net::HTTP.method(:start)
    ENV["FCM_SERVER_KEY"] = "test_server_key_abc"
  end

  def teardown
    ENV["FCM_SERVER_KEY"] = @original_server_key
    Net::HTTP.define_singleton_method(:start, @original_start)
  end

  test "enviar sends POST to FCM with correct payload" do
    captured_request = nil

    Net::HTTP.define_singleton_method(:start) do |*_args, **_opts, &block|
      http = Object.new
      http.define_singleton_method(:request) do |req|
        captured_request = req
        resp = Object.new
        resp.define_singleton_method(:code) { "200" }
        resp.define_singleton_method(:body) { '{"success":1}' }
        resp
      end
      block.call(http)
    end

    @sender.enviar(@notificacion, @fcm_token)

    assert captured_request
    assert_equal "/fcm/send", captured_request.path
    assert_includes captured_request["Authorization"], "key=test_server_key_abc"
    assert_includes captured_request["Content-Type"], "application/json"

    body_data = JSON.parse(captured_request.body)
    assert_equal @fcm_token, body_data["to"]
    assert_equal "Asistencia marcada", body_data["notification"]["title"]
    assert_equal "Entrada — 08:32 hs | Ubicación válida", body_data["notification"]["body"]
    assert_equal "asistencia", body_data["data"]["type"]
    assert_equal "historial", body_data["data"]["screen"]
    assert_equal "1", body_data["data"]["marcacion_id"]
  end

  test "enviar raises error when FCM returns non-200" do
    Net::HTTP.define_singleton_method(:start) do |*_args, **_opts, &block|
      http = Object.new
      http.define_singleton_method(:request) do |_req|
        resp = Object.new
        resp.define_singleton_method(:code) { "400" }
        resp.define_singleton_method(:body) { '{"error":"Invalid token"}' }
        resp
      end
      block.call(http)
    end

    assert_raises(RuntimeError) { @sender.enviar(@notificacion, @fcm_token) }
  end

  test "enviar uses SSL and correct host" do
    captured_host = nil
    captured_port = nil
    captured_ssl = nil

    Net::HTTP.define_singleton_method(:start) do |host, port, **opts, &block|
      captured_host = host
      captured_port = port
      captured_ssl = opts[:use_ssl]
      http = Object.new
      http.define_singleton_method(:request) do |_req|
        resp = Object.new
        resp.define_singleton_method(:code) { "200" }
        resp.define_singleton_method(:body) { '{"success":1}' }
        resp
      end
      block.call(http)
    end

    @sender.enviar(@notificacion, @fcm_token)

    assert_equal "fcm.googleapis.com", captured_host
    assert_equal 443, captured_port
    assert captured_ssl
  end
end
