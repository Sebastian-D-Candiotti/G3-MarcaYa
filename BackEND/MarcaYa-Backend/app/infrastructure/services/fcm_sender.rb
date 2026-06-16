# frozen_string_literal: true

require "json"
require "net/http"
require "jwt"
require "openssl"

module Infrastructure
  module Services
    # Adapter that sends push notifications via the Firebase Cloud Messaging
    # HTTP v1 API. Reads the service account JSON from ENV['FIREBASE_SERVICE_ACCOUNT_JSON'].
    #
    # Implements Ports::Driven::IPushSender (or whichever port is defined)
    class FcmSender
      OAUTH2_AUD = "https://oauth2.googleapis.com/token"
      OAUTH2_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"

      def enviar(notificacion, fcm_token)
        service_account_json = ENV["FIREBASE_SERVICE_ACCOUNT_JSON"]
        if service_account_json.blank?
          raise "FIREBASE_SERVICE_ACCOUNT_JSON is not configured in environment variables"
        end

        credentials = JSON.parse(service_account_json)
        project_id = credentials["project_id"]
        client_email = credentials["client_email"]
        private_key_raw = credentials["private_key"]

        if project_id.blank? || client_email.blank? || private_key_raw.blank?
          raise "Invalid FIREBASE_SERVICE_ACCOUNT_JSON: missing project_id, client_email or private_key"
        end

        access_token = generate_access_token(client_email, private_key_raw)

        url = "https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send"
        uri = URI(url)

        payload = {
          message: {
            token: fcm_token,
            notification: {
              title: notificacion.title,
              body: notificacion.body
            },
            data: notificacion.data.transform_keys(&:to_s)
          }
        }

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          request = Net::HTTP::Post.new(uri.path, {
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/json"
          })
          request.body = payload.to_json
          http.request(request)
        end

        unless response.code.to_i == 200
          raise "FCM HTTP v1 error: #{response.code} — #{response.body}"
        end

        true
      end

      private

      def generate_access_token(client_email, private_key_raw)
        private_key = OpenSSL::PKey::RSA.new(private_key_raw)
        now = Time.now.to_i

        payload = {
          iss: client_email,
          scope: OAUTH2_SCOPE,
          aud: OAUTH2_AUD,
          iat: now,
          exp: now + 3600 # 1 hour expiry
        }

        jwt = JWT.encode(payload, private_key, "RS256")

        uri = URI(OAUTH2_AUD)
        response = Net::HTTP.post_form(uri, {
          grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
          assertion: jwt
        })

        if response.code.to_i != 200
          raise "Failed to obtain Google OAuth2 access token: #{response.code} — #{response.body}"
        end

        JSON.parse(response.body)["access_token"]
      end
    end
  end
end
