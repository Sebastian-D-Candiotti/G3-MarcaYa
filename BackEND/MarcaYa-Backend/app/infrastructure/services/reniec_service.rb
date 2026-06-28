# app/domain/services/reniec_service.rb
# frozen_string_literal: true

require "net/http"
require "json"

module Infrastructure
  module Services
    class ReniecService
      API_URL = "https://peruapi.com/api/dni"

      def consultar(dni)
        uri = URI("#{API_URL}/#{dni}")

        request = Net::HTTP::Get.new(uri)
        request["X-API-KEY"] = ENV.fetch("RENIEC_API_TOKEN")

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        return nil unless response.code.to_i == 200

        data = JSON.parse(response.body)

        {
          nombres: data["nombres"] || data["nombre"],
          apellido_paterno: data["apellido_paterno"],
          apellido_materno: data["apellido_materno"]
        }
      rescue KeyError
        raise Domain::Errors::ValidacionError, "Falta configurar RENIEC_API_TOKEN"
      rescue StandardError => e
        Rails.logger.error("Error consultando PeruAPI DNI: #{e.message}") if defined?(Rails)
        nil
      end
    end
  end
end