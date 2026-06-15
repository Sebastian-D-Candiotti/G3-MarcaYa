# frozen_string_literal: true

# Encapsulates the orchestration logic for sending a push notification via
# SendPushNotificationJob#ejecutar so it can be unit-tested without DI.
class SendPushNotificationJob < ApplicationJob
  queue_as :push_notifications

  def perform(empleado_id, marcacion_id)
    dispositivo_repo = Rails.configuration.di.repos[:dispositivo]
    asistencia_repo = Rails.configuration.di.repos[:asistencia]
    fcm_sender = Rails.configuration.di.fcm_sender

    ejecutar(empleado_id, marcacion_id,
             dispositivo_repo: dispositivo_repo,
             asistencia_repo: asistencia_repo,
             fcm_sender: fcm_sender)
  end

  # Internal method extracted for testability — receives all dependencies explicitly.
  def ejecutar(empleado_id, marcacion_id, dispositivo_repo:, asistencia_repo:, fcm_sender:)
    registro = asistencia_repo.find_by_id!(marcacion_id)
    tokens = dispositivo_repo.activos_por_empleado(empleado_id)
    return if tokens.empty?

    notificacion = build_notificacion(registro)

    tokens.each do |device|
      fcm_sender.enviar(notificacion, device.fcm_token)
    end
  end

  private

  def build_notificacion(registro)
    tipo = registro.tipo_marcacion == "ENTRADA" ? "Entrada" : "Salida"
    hora = registro.fecha_hora.strftime("%H:%M")
    ubicacion = registro.valida_gps ? "Ubicación válida" : "Fuera del área permitida"
    body = "#{tipo} — #{hora} hs | #{ubicacion}"

    Domain::ValueObjects::NotificacionPush.new(
      title: "Asistencia registrada",
      body: body,
      data: { type: "asistencia", screen: "historial", marcacion_id: registro.id.to_s }
    )
  end
end
