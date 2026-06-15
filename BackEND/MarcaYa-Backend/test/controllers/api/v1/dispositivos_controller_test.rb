# frozen_string_literal: true

require "test_helper"

class Api::V1::DispositivosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usuario = usuarios(:empresa_activa)
    @token = "nuevo_token_fcm_abc"
    @platform = "android"
  end

  test "registrar creates new device and returns 201" do
    authenticate_as :empresa_activa

    assert_difference -> { Infrastructure::Orm::DeviceRecord.count }, 1 do
      post api_v1_dispositivo_registrar_url,
           params: { fcm_token: @token, platform: @platform },
           as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal @token, body["fcm_token"]
    assert_equal @platform, body["platform"]
    assert body["mensaje"].present?
  end

  test "registrar updates existing token and returns 200" do
    # Pre-create a device with this token for the authenticated user
    existing = Infrastructure::Orm::DeviceRecord.create!(
      user_id: @usuario.id,
      fcm_token: "token_existente",
      platform: "android"
    )

    authenticate_as :empresa_activa

    assert_no_difference -> { Infrastructure::Orm::DeviceRecord.count } do
      post api_v1_dispositivo_registrar_url,
           params: { fcm_token: "token_existente", platform: "ios" },
           as: :json
    end

    assert_response :ok
    body = response.parsed_body
    assert_equal "token_existente", body["fcm_token"]
    assert_equal "ios", body["platform"]
  end

  test "registrar without auth returns 401" do
    post api_v1_dispositivo_registrar_url,
         params: { fcm_token: @token, platform: @platform },
         as: :json

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "No autorizado", body["error"]
  end
end
