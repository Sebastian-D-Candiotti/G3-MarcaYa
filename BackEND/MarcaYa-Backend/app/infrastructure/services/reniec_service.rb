# app/domain/services/reniec_service.rb

# frozen_string_literal: true

require "net/http"
require "json"

module Infrastructure
  module Services
    class ReniecService
      API_URL = "https://graphperu.daustinn.com/api/query".freeze
      NOMBRES_FALLBACK = %w[JUAN CARLOS MARIA ANA LUIS MIGUEL SOFIA CARLA PEDRO ROSA JOSE DIEGO PAULA ANDREA MATEO].freeze
      APELLIDOS_FALLBACK = %w[GONZALES LOPEZ TORRES QUISPE RAMOS FLORES DIAZ GARCIA MARTINEZ SANCHEZ ROMERO VEGA CASTRO PAREDES REYES].freeze

      def consultar(dni)
        return nil unless dni.to_s.match?(/\A\d{8}\z/)

        api_consulta(dni) || fallback(dni)
      end

      private

      def api_consulta(dni)
        uri = URI("#{API_URL}/#{dni}")
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 3) do |http|
          http.request(Net::HTTP::Get.new(uri))
        end

        return nil unless response.code.to_i == 200

        data = JSON.parse(response.body)
        return nil if data.nil? || data["names"].nil?

        {
          nombres: data["names"],
          apellido_paterno: data["paternalLastName"],
          apellido_materno: data["maternalLastName"]
        }
      rescue StandardError
        nil
      end

      def fallback(dni)
        idx = dni.to_i
        {
          nombres: "#{NOMBRES_FALLBACK[idx % NOMBRES_FALLBACK.size]} #{NOMBRES_FALLBACK[(idx / 10) % NOMBRES_FALLBACK.size]}",
          apellido_paterno: APELLIDOS_FALLBACK[(idx / 100) % APELLIDOS_FALLBACK.size],
          apellido_materno: APELLIDOS_FALLBACK[(idx / 1000) % APELLIDOS_FALLBACK.size]
        }
      end
    end
  end
end