# frozen_string_literal: true

require "json"
require "net/http"

module Infrastructure
  module Services
    # Adapter that sends push notifications via the Firebase Cloud Messaging
    # Legacy HTTP API. Reads the server key from ENV['FCM_SERVER_KEY'].
    #
    # Implements Ports::Driven::IPushSender
    class FcmSender
      FCM_URL = "https://fcm.googleapis.com/fcm/send"
      FCM_HOST = "fcm.googleapis.com"
      FCM_PORT = 443
      FCM_PATH = "/fcm/send"

      def enviar(notificacion, fcm_token)
        server_key = ENV.fetch("FCM_SERVER_KEY") do
          raise "FCM_SERVER_KEY is not configured"
        end

        payload = {
          to: fcm_token,
          notification: {
            title: notificacion.title,
            body: notificacion.body
          },
          data: notificacion.data.transform_keys(&:to_s)
        }

        response = Net::HTTP.start(FCM_HOST, FCM_PORT, use_ssl: true) do |http|
          request = Net::HTTP::Post.new(FCM_PATH, {
            "Authorization" => "key=#{server_key}",
            "Content-Type" => "application/json"
          })
          request.body = payload.to_json
          http.request(request)
        end

        raise "FCM error: #{response.code} — #{response.body}" unless response.code.to_i == 200

        true
      end
    end
  end
end
