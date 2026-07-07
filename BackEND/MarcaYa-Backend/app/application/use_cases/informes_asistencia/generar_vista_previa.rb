# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class GenerarVistaPrevia < Base
        def initialize(snapshot_builder: ConstruirSnapshot.new)
          @snapshot_builder = snapshot_builder
        end

        def call(current_user:, params:)
          tipo = normalizar_tipo(params[:tipo_periodo] || params[:tipo])
          validar_tipo!(tipo)
          fecha_inicio = parse_fecha(params[:fecha_inicio], "fecha_inicio")
          fecha_fin = parse_fecha(params[:fecha_fin], "fecha_fin")
          validar_rango_por_tipo!(tipo, fecha_inicio, fecha_fin)

          empresa = params[:empresa_id].present? ? empresa_autorizada(current_user, params[:empresa_id]) : empresa_principal(current_user)
          return Resultado.fail("No autorizado para esta empresa", status: :forbidden) unless empresa

          snapshot = @snapshot_builder.call(
            empresa: empresa,
            tipo_periodo: tipo,
            fecha_inicio: fecha_inicio,
            fecha_fin: fecha_fin
          )

          Resultado.ok(snapshot)
        rescue ArgumentError => e
          Resultado.fail(e.message, status: :unprocessable_entity)
        end
      end
    end
  end
end
