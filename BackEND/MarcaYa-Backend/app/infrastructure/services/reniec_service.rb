# app/domain/services/reniec_service.rb

# frozen_string_literal: true

require "net/http"
require "json"

module Infrastructure
  module Services
    class ReniecService
      API_URL = "https://graphperu.daustinn.com/api/query".freeze

      def consultar(dni)
        return nil unless dni.to_s.match?(/\A\d{8}\z/)
        return datos_fake(dni) if defined?(Rails) && Rails.env.test?

        api_consulta(dni)
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
      rescue Net::TimeoutError, Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
        nil
      end

      def datos_fake(dni)
        idx = dni.to_i
        nombres_base = %w[JUAN CARLOS MARIA ANA LUIS MIGUEL SOFIA CARLA PEDRO ROSA]
        apellidos_base = %w[GONZALES LOPEZ TORRES QUISPE RAMOS FLORES DIAZ GARCIA MARTINEZ SANCHEZ]
        {
          nombres: "#{nombres_base[idx % nombres_base.size]} #{nombres_base[(idx / 10) % nombres_base.size]}",
          apellido_paterno: apellidos_base[(idx / 100) % apellidos_base.size],
          apellido_materno: apellidos_base[(idx / 1000) % apellidos_base.size]
        }
      end
    end
  end
end