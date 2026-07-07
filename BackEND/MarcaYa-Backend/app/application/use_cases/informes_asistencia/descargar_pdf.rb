# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class DescargarPdf < Base
        def initialize(pdf_service: Infrastructure::Services::AsistenciaPdfService.new)
          @pdf_service = pdf_service
        end

        def call(current_user:, id:)
          record = Infrastructure::Orm::InformeAsistenciaRecord.find_by(id: id)
          return Resultado.fail("Informe no encontrado", status: :not_found) unless record
          return Resultado.fail("No autorizado para esta empresa", status: :forbidden) unless empresa_autorizada(current_user, record.empresa_id)

          pdf = @pdf_service.call(record)
          Resultado.ok(
            {
              filename: filename_for(record),
              content_type: "application/pdf",
              bytes: pdf
            }
          )
        end

        private

        def filename_for(record)
          empresa = record.snapshot.dig("empresa", "nombre").to_s
          slug = empresa.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "").presence || "empresa"
          periodo = record.fecha_inicio.strftime("%Y_%m")
          "informe_asistencia_#{slug}_#{periodo}.pdf"
        end
      end
    end
  end
end
