# app/domain/services/reniec_service.rb

# frozen_string_literal: true

# require "net/http"
# require "json"

module Infrastructure
  module Services
    class ReniecService
      def consultar(dni)
        datos_fake = {
          "12345678" => {
            nombres: "JOAQUIN",
            apellido_paterno: "GONZALES",
            apellido_materno: "PEREZ"
          },
          "87654321" => {
            nombres: "MARIA",
            apellido_paterno: "LOPEZ",
            apellido_materno: "RAMOS"
          },
          "11223344" => {
            nombres: "LUIS",
            apellido_paterno: "TORRES",
            apellido_materno: "DIAZ"
          },
          "44332211" => {
            nombres: "ANA",
            apellido_paterno: "QUISPE",
            apellido_materno: "FLORES"
          }
        }

        datos_fake[dni]
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