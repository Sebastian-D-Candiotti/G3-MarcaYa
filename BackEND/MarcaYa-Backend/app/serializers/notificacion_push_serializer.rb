# frozen_string_literal: true

module Serializer
  # Formats a NotificacionPush value object into the FCM HTTP API payload.
  module NotificacionPushSerializer
    def self.as_json(notificacion, fcm_token:)
      return nil if notificacion.nil? || fcm_token.nil?

      {
        to: fcm_token,
        notification: {
          title: notificacion.title,
          body: notificacion.body
        },
        data: notificacion.data.transform_keys(&:to_s)
      }
    end
  end
end
