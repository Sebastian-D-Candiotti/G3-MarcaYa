# app/domain/services/reniec_service.rb

# frozen_string_literal: true

# require "net/http"
# require "json"

module Infrastructure
  module Services
    class ReniecService
      NOMBRES = %w[JUAN CARLOS MARIA ANA LUIS MIGUEL SOFIA CARLA PEDRO ROSA JOSE DIEGO PAULA ANDREA MATEO]
      APELLIDOS = %w[GONZALES LOPEZ TORRES QUISPE RAMOS FLORES DIAZ GARCIA MARTINEZ SANCHEZ ROMERO VEGA CASTRO PAREDES REYES]

      def consultar(dni)
        return nil unless dni.to_s.match?(/\A\d{8}\z/)

        idx = dni.to_i
        {
          nombres: "#{NOMBRES[idx % NOMBRES.size]} #{NOMBRES[(idx / 10) % NOMBRES.size]}",
          apellido_paterno: APELLIDOS[(idx / 100) % APELLIDOS.size],
          apellido_materno: APELLIDOS[(idx / 1000) % APELLIDOS.size]
        }
      end

      # Versión futura con API real
      #
      # def consultar(dni)
      #   uri = URI("https://api.ejemplo.com/dni/#{dni}")
      #
      #   request = Net::HTTP::Get.new(uri)
      #   request["Authorization"] = "Bearer #{ENV.fetch('RENIEC_API_TOKEN')}"
      #
      #   response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      #     http.request(request)
      #   end
      #
      #   return nil unless response.code.to_i == 200
      #
      #   data = JSON.parse(response.body)
      #
      #   {
      #     nombres: data["nombres"],
      #     apellido_paterno: data["apellido_paterno"],
      #     apellido_materno: data["apellido_materno"]
      #   }
      # rescue StandardError
      #   nil
      # end
    end
  end
end