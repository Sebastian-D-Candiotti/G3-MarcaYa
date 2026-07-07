# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class ListarHistorial < Base
        def call(current_user:, params:)
          empresa = params[:empresa_id].present? ? empresa_autorizada(current_user, params[:empresa_id]) : empresa_principal(current_user)
          return Resultado.fail("No autorizado para esta empresa", status: :forbidden) unless empresa

          page = [params.fetch(:page, 1).to_i, 1].max
          per_page = [[params.fetch(:per_page, 20).to_i, 1].max, 100].min

          scope = Infrastructure::Orm::InformeAsistenciaRecord
                  .where(empresa_id: empresa.id)
                  .order(fecha_inicio: :desc, created_at: :desc)
          scope = scope.where(tipo_periodo: normalizar_tipo(params[:tipo_periodo])) if params[:tipo_periodo].present?
          scope = scope.where(estado: params[:estado].to_s.upcase) if params[:estado].present?
          scope = scope.where("EXTRACT(YEAR FROM fecha_inicio) = ?", params[:anio].to_i) if params[:anio].present?
          scope = scope.where("EXTRACT(MONTH FROM fecha_inicio) = ?", params[:mes].to_i) if params[:mes].present?

          total = scope.count
          records = scope.offset((page - 1) * per_page).limit(per_page)

          Resultado.ok(
            {
              items: records.map { |record| serializar_record(record).except(:snapshot) },
              pagination: {
                page: page,
                per_page: per_page,
                total: total
              }
            }
          )
        end
      end
    end
  end
end
