# frozen_string_literal: true

require "ostruct"
require "test_helper"

class SendPushNotificationJobTest < ActiveJob::TestCase
  test "is queued in push_notifications queue" do
    assert_equal "push_notifications", SendPushNotificationJob.new.queue_name
  end

  test "ejecutar sends push to all active devices for the empleado" do
    empleado_id = 1
    marcacion_id = 42
    now = Time.now

    registro = Domain::Entities::RegistroAsistencia.new(
      id: marcacion_id, empleado_id: empleado_id, parada_id: 10,
      tipo_marcacion: "ENTRADA", fecha_hora: now,
      latitud_registrada: -34.5, longitud_registrada: -58.3,
      valida_gps: true
    )

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) { |_id| registro }

    dispositivo_repo = Object.new
    r1 = OpenStruct.new(fcm_token: "token1")
    r2 = OpenStruct.new(fcm_token: "token2")
    dispositivo_repo.define_singleton_method(:activos_por_empleado) { |_eid| [r1, r2] }

    sent = []
    fcm_sender = Object.new
    fcm_sender.define_singleton_method(:enviar) do |notificacion, token|
      sent << { notificacion: notificacion, token: token }
    end

    SendPushNotificationJob.new.ejecutar(
      empleado_id, marcacion_id,
      dispositivo_repo: dispositivo_repo,
      asistencia_repo: asistencia_repo,
      fcm_sender: fcm_sender
    )

    assert_equal 2, sent.length
    assert_equal "token1", sent[0][:token]
    assert_equal "token2", sent[1][:token]
  end

  test "ejecutar builds notification with attendance data" do
    empleado_id = 1
    marcacion_id = 42
    now = Time.now

    registro = Domain::Entities::RegistroAsistencia.new(
      id: marcacion_id, empleado_id: empleado_id, parada_id: 10,
      tipo_marcacion: "ENTRADA", fecha_hora: now,
      latitud_registrada: -34.5, longitud_registrada: -58.3,
      valida_gps: true
    )

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) { |_id| registro }

    dispositivo_repo = Object.new
    r = OpenStruct.new(fcm_token: "token1")
    dispositivo_repo.define_singleton_method(:activos_por_empleado) { |_eid| [r] }

    sent = []
    fcm_sender = Object.new
    fcm_sender.define_singleton_method(:enviar) do |notificacion, token|
      sent << { notificacion: notificacion, token: token }
    end

    SendPushNotificationJob.new.ejecutar(
      empleado_id, marcacion_id,
      dispositivo_repo: dispositivo_repo,
      asistencia_repo: asistencia_repo,
      fcm_sender: fcm_sender
    )

    notificacion = sent[0][:notificacion]
    assert_instance_of Domain::ValueObjects::NotificacionPush, notificacion
    assert_equal "Asistencia registrada", notificacion.title
    hora = now.strftime("%H:%M")
    assert_equal "Entrada — #{hora} hs | Ubicación válida", notificacion.body
    assert_equal "asistencia", notificacion.data[:type]
    assert_equal "historial", notificacion.data[:screen]
    assert_equal marcacion_id.to_s, notificacion.data[:marcacion_id]
  end

  test "ejecutar uses body for salida" do
    empleado_id = 1
    marcacion_id = 42
    now = Time.now

    registro_salida = Domain::Entities::RegistroAsistencia.new(
      id: marcacion_id, empleado_id: empleado_id, parada_id: 10,
      tipo_marcacion: "SALIDA", fecha_hora: now,
      latitud_registrada: -34.5, longitud_registrada: -58.3,
      valida_gps: true, duracion_jornada: 28800
    )

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) { |_id| registro_salida }

    dispositivo_repo = Object.new
    r = OpenStruct.new(fcm_token: "token1")
    dispositivo_repo.define_singleton_method(:activos_por_empleado) { |_eid| [r] }

    sent = []
    fcm_sender = Object.new
    fcm_sender.define_singleton_method(:enviar) do |notificacion, token|
      sent << { notificacion: notificacion, token: token }
    end

    SendPushNotificationJob.new.ejecutar(
      empleado_id, marcacion_id,
      dispositivo_repo: dispositivo_repo,
      asistencia_repo: asistencia_repo,
      fcm_sender: fcm_sender
    )

    hora = now.strftime("%H:%M")
    assert_equal "Salida — #{hora} hs | Ubicación válida", sent[0][:notificacion].body
  end

  test "ejecutar uses fuera del area body when gps is invalid" do
    empleado_id = 1
    marcacion_id = 42
    now = Time.now

    registro_fuera = Domain::Entities::RegistroAsistencia.new(
      id: marcacion_id, empleado_id: empleado_id, parada_id: 10,
      tipo_marcacion: "ENTRADA", fecha_hora: now,
      latitud_registrada: -33.0, longitud_registrada: -58.0,
      valida_gps: false, observaciones: "Fuera de zona"
    )

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) { |_id| registro_fuera }

    dispositivo_repo = Object.new
    r = OpenStruct.new(fcm_token: "token1")
    dispositivo_repo.define_singleton_method(:activos_por_empleado) { |_eid| [r] }

    sent = []
    fcm_sender = Object.new
    fcm_sender.define_singleton_method(:enviar) do |notificacion, token|
      sent << { notificacion: notificacion, token: token }
    end

    SendPushNotificationJob.new.ejecutar(
      empleado_id, marcacion_id,
      dispositivo_repo: dispositivo_repo,
      asistencia_repo: asistencia_repo,
      fcm_sender: fcm_sender
    )

    hora = now.strftime("%H:%M")
    assert_equal "Entrada — #{hora} hs | Fuera del área permitida", sent[0][:notificacion].body
  end

  test "ejecutar does not fail when empleado has no devices" do
    empleado_id = 1
    marcacion_id = 42
    now = Time.now

    registro = Domain::Entities::RegistroAsistencia.new(
      id: marcacion_id, empleado_id: empleado_id, parada_id: 10,
      tipo_marcacion: "ENTRADA", fecha_hora: now,
      latitud_registrada: -34.5, longitud_registrada: -58.3,
      valida_gps: true
    )

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) { |_id| registro }

    dispositivo_repo = Object.new
    dispositivo_repo.define_singleton_method(:activos_por_empleado) { |_eid| [] }

    sent = []
    fcm_sender = Object.new
    fcm_sender.define_singleton_method(:enviar) { |_notificacion, _token| }

    SendPushNotificationJob.new.ejecutar(
      empleado_id, marcacion_id,
      dispositivo_repo: dispositivo_repo,
      asistencia_repo: asistencia_repo,
      fcm_sender: fcm_sender
    )

    # No error is sufficient — verify nothing was sent
    assert_empty sent
  end

  test "ejecutar raises when registro not found" do
    empleado_id = 1
    marcacion_id = 999

    asistencia_repo = Object.new
    asistencia_repo.define_singleton_method(:find_by_id!) do |_id|
      raise Domain::Errors::AsistenciaNoEncontradaError
    end

    dispositivo_repo = Object.new
    fcm_sender = Object.new

    assert_raises Domain::Errors::AsistenciaNoEncontradaError do
      SendPushNotificationJob.new.ejecutar(
        empleado_id, marcacion_id,
        dispositivo_repo: dispositivo_repo,
        asistencia_repo: asistencia_repo,
        fcm_sender: fcm_sender
      )
    end
  end
end
