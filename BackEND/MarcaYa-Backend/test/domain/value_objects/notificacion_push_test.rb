# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/errors"
require_relative "../../../app/domain/value_objects/notificacion_push"

class Domain::ValueObjects::NotificacionPushTest < Minitest::Test
  # --- Construction ---

  def test_valid_notification_with_all_fields
    notif = Domain::ValueObjects::NotificacionPush.new(
      title: "Asistencia marcada",
      body: "Entrada — 08:32 hs | Ubicación válida",
      data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
    )

    assert_equal "Asistencia marcada", notif.title
    assert_equal "Entrada — 08:32 hs | Ubicación válida", notif.body
    assert_equal "asistencia", notif.data[:type]
    assert_equal "historial", notif.data[:screen]
    assert_equal "1", notif.data[:marcacion_id]
  end

  def test_valid_with_exit_body_format
    notif = Domain::ValueObjects::NotificacionPush.new(
      title: "Asistencia marcada",
      body: "Salida — 17:05 hs | Fuera del área permitida",
      data: { type: "asistencia", screen: "historial", marcacion_id: "42" }
    )

    assert_equal "Salida — 17:05 hs | Fuera del área permitida", notif.body
    assert_equal "42", notif.data[:marcacion_id]
  end

  # --- Validation: title ---

  def test_invalid_with_nil_title
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: nil, body: "Entrada — 08:00 hs | Ubicación válida",
        data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
      )
    end
  end

  def test_invalid_with_empty_title
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "", body: "Entrada — 08:00 hs | Ubicación válida",
        data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
      )
    end
  end

  def test_invalid_with_blank_title
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "   ", body: "Entrada — 08:00 hs | Ubicación válida",
        data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
      )
    end
  end

  # --- Validation: body ---

  def test_invalid_with_nil_body
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "Asistencia marcada", body: nil,
        data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
      )
    end
  end

  def test_invalid_with_empty_body
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "Asistencia marcada", body: "",
        data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
      )
    end
  end

  # --- Validation: data ---

  def test_invalid_with_empty_data_hash
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "Asistencia marcada", body: "Entrada — 08:00 hs | Ubicación válida",
        data: {}
      )
    end
  end

  def test_invalid_with_nil_data
    assert_raises(Domain::Errors::ValidacionError) do
      Domain::ValueObjects::NotificacionPush.new(
        title: "Asistencia marcada", body: "Entrada — 08:00 hs | Ubicación válida",
        data: nil
      )
    end
  end

  # --- to_h ---

  def test_to_h_returns_hash_with_all_fields
    notif = Domain::ValueObjects::NotificacionPush.new(
      title: "Asistencia marcada",
      body: "Entrada — 08:32 hs | Ubicación válida",
      data: { type: "asistencia", screen: "historial", marcacion_id: "1" }
    )

    hash = notif.to_h
    assert_instance_of Hash, hash
    assert_equal "Asistencia marcada", hash[:title]
    assert_equal "Entrada — 08:32 hs | Ubicación válida", hash[:body]
    assert_equal "1", hash[:data][:marcacion_id]
  end
end
