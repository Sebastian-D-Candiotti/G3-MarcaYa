# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Domain
  module Services
    class SunatService
      MOCK_EMPRESAS = {
        "20100055237" => { razon_social: "Alicorp S.A.A.", correo: "contacto@alicorp.com.pe" },
        "20100047218" => { razon_social: "Banco de Credito del Peru", correo: "contacto@bcp.com.pe" },
        "20100192790" => { razon_social: "Gloria S.A.", correo: "contacto@gloria.com.pe" },
        "20100053455" => { razon_social: "Banco Internacional del Peru S.A.A. - Interbank", correo: "contacto@interbank.pe" },
        "20100113610" => { razon_social: "Union de Cervecerias Peruanas Backus y Johnston S.A.A.", correo: "contacto@backus.pe" },
        "20100142857" => { razon_social: "Aenza S.A.A.", correo: "contacto@aenza.com.pe" },
        "20100128056" => { razon_social: "Saga Falabella S.A.", correo: "contacto@falabella.com.pe" },
        "20516643685" => { razon_social: "Tiendas Peruanas S.A.", correo: "contacto@oechsle.pe" },
        "20100070953" => { razon_social: "Supermercados Peruanos S.A.", correo: "contacto@spsa.pe" },
        "20100079586" => { razon_social: "Compania de Minas Buenaventura S.A.A.", correo: "contacto@buenaventura.pe" },
        "20100017491" => { razon_social: "Telefonica del Peru S.A.A.", correo: "contacto@telefonica.pe" },
        "20253435154" => { razon_social: "Inretail Pharma S.A.", correo: "contacto@inretailpharma.pe" },
        "20100028698" => { razon_social: "Ferreyros S.A.", correo: "contacto@ferreyros.com.pe" },
        "20100012261" => { razon_social: "Rimac Seguros y Reaseguros", correo: "contacto@rimac.com.pe" },
        "20100030595" => { razon_social: "Scotiabank Peru S.A.A.", correo: "contacto@scotiabank.com.pe" },
        "20100204712" => { razon_social: "Pacifico Compania de Seguros y Reaseguros", correo: "contacto@pacifico.com.pe" },
        "20100004955" => { razon_social: "Banco Continental BBVA", correo: "contacto@bbva.com" },
        "20100012422" => { razon_social: "Sociedad Minera Cerro Verde S.A.A.", correo: "contacto@cerroverde.pe" },
        "20100063906" => { razon_social: "Southern Peru Copper Corporation", correo: "contacto@southern.com.pe" },
        "20306443657" => { razon_social: "Sodimac Peru S.A.", correo: "contacto@sodimac.com.pe" },
        "20100073979" => { razon_social: "Cencosud Retail Peru S.A.", correo: "contacto@cencosud.com.pe" },
        "20100032709" => { razon_social: "Luz del Sur S.A.A.", correo: "contacto@luzdelsur.com.pe" },
        "20100026210" => { razon_social: "Enel Distribucion Peru S.A.A.", correo: "contacto@enel.pe" },
        "20100017903" => { razon_social: "Cementos Pacasmayo S.A.A.", correo: "contacto@pacasmayo.com.pe" },
        "20100054770" => { razon_social: "UNACEM S.A.A.", correo: "contacto@unacem.com.pe" },
        "20509088673" => { razon_social: "Hipermercados Tottus S.A.", correo: "contacto@tottus.com.pe" },
        "20504306472" => { razon_social: "Makro Supermayorista S.A.", correo: "contacto@makro.com.pe" },
        "20100144396" => { razon_social: "Minera Las Bambas S.A.", correo: "contacto@lasbambas.pe" },
        "20100187877" => { razon_social: "Compania Minera Antamina S.A.", correo: "contacto@antamina.com" },
        "20100154278" => { razon_social: "Petroleos del Peru - Petroperu S.A.", correo: "contacto@petroperu.com.pe" },
        "20100018624" => { razon_social: "Refineria La Pampilla S.A.A.", correo: "contacto@repsol.com" },
        "20100039207" => { razon_social: "Latam Airlines Peru S.A.", correo: "contacto@latam.com" },
        "20100040639" => { razon_social: "Corporacion Aceros Arequipa S.A.", correo: "contacto@acerosarequipa.com" },
        "20100062331" => { razon_social: "Siderurgica del Peru S.A.A.", correo: "contacto@sider.com.pe" },
        "20100058929" => { razon_social: "Entel Peru S.A.", correo: "contacto@entel.pe" },
        "20503612545" => { razon_social: "America Movil Peru S.A.C. - Claro", correo: "contacto@claro.com.pe" },
        "20100094038" => { razon_social: "San Fernando S.A.", correo: "contacto@sanfernando.pe" },
        "20100127165" => { razon_social: "Corporacion Lindley S.A.", correo: "contacto@lindley.pe" },
        "20100084580" => { razon_social: "Nestle Peru S.A.", correo: "contacto@nestle.com.pe" },
        "20100116805" => { razon_social: "Kimberly-Clark Peru S.R.L.", correo: "contacto@kcc.com" },
        "20100057019" => { razon_social: "Procter & Gamble Peru S.R.L.", correo: "contacto@pg.com" },
        "20100005331" => { razon_social: "Cosapi S.A.", correo: "contacto@cosapi.com.pe" },
        "20101416721" => { razon_social: "GyM S.A.", correo: "contacto@gym.com.pe" },
        "20502390277" => { razon_social: "Los Portales S.A.", correo: "contacto@losportales.com.pe" },
        "20100051321" => { razon_social: "Clinica Javier Prado S.A.", correo: "contacto@clinicajavierprado.com.pe" },
        "20100049687" => { razon_social: "Clinica Internacional S.A.", correo: "contacto@clinicainternacional.com.pe" },
        "20100007202" => { razon_social: "Clinica Anglo Americana S.A.", correo: "contacto@clinicaangloamericana.pe" },
        "20100010217" => { razon_social: "Clinica San Felipe S.A.", correo: "contacto@clinicasanfelipe.com" },
        "20100234719" => { razon_social: "Ransa Comercial S.A.", correo: "contacto@ransa.net" },
        "20100054346" => { razon_social: "Talma Servicios Aeroportuarios S.A.", correo: "contacto@talma.com.pe" }
      }.freeze

      def self.buscar_por_ruc(ruc)
        token = ENV["SUNAT_API_TOKEN"]
        
        if token.present?
          begin
            uri = URI.parse("https://dniruc.apisperu.com/api/v1/ruc/#{ruc}")
            request = Net::HTTP::Get.new(uri)
            request["Authorization"] = "Bearer #{token}"
            request["Accept"] = "application/json"

            options = { use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5 }
            response = Net::HTTP.start(uri.hostname, uri.port, options) do |http|
              http.request(request)
            end

            if response.code == "200"
              data = JSON.parse(response.body)
              if data["ruc"].present? && data["razonSocial"].present?
                razon_social = data["razonSocial"]
                correo = generar_correo_oficial(razon_social)
                return Entities::SunatEmpresa.new(
                  ruc: ruc,
                  razon_social: razon_social,
                  correo_oficial: correo
                )
              end
            end
          rescue StandardError => e
            Rails.logger.error("Error al consultar API SUNAT: #{e.message}")
          end
        end

        # Fallback a la lista estática / mock
        if MOCK_EMPRESAS.key?(ruc)
          mock_data = MOCK_EMPRESAS[ruc]
          return Entities::SunatEmpresa.new(
            ruc: ruc,
            razon_social: mock_data[:razon_social],
            correo_oficial: mock_data[:correo]
          )
        end

        nil
      end

      def self.listar_todas
        MOCK_EMPRESAS.map do |ruc, data|
          Entities::SunatEmpresa.new(
            ruc: ruc,
            razon_social: data[:razon_social],
            correo_oficial: data[:correo]
          )
        end
      end

      def self.enmascarar_correo(correo)
        return "" if correo.blank?
        parts = correo.split("@")
        return correo if parts.length != 2

        user = parts[0]
        domain = parts[1]

        masked_user = if user.length <= 2
                        user + "***"
                      else
                        user[0..1] + "***"
                      end

        "#{masked_user}@#{domain}"
      end

      private

      def self.generar_correo_oficial(razon_social)
        normalized = razon_social.downcase
                      .gsub(/s\.a\.c\.|s\.a\.|s\.r\.l\.|e\.i\.r\.l\./, "")
                      .strip
                      .gsub(/[^a-z0-9]/, "")
        "admin@#{normalized}.com.pe"
      end
    end
  end
end
