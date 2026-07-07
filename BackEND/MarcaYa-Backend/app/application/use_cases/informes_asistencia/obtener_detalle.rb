# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class ObtenerDetalle < Base
        def call(current_user:, id:)
          record = Infrastructure::Orm::InformeAsistenciaRecord.find_by(id: id)
          return Resultado.fail("Informe no encontrado", status: :not_found) unless record
          return Resultado.fail("No autorizado para esta empresa", status: :forbidden) unless empresa_autorizada(current_user, record.empresa_id)

          Resultado.ok(serializar_record(record))
        end
      end
    end
  end
end
