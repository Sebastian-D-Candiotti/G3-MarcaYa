module Api
  module V1
    class EstadisticasController < BaseController

      def initialize
        super
        @estadisticas_facade = Application::Facades::EstadisticasFacade.new
      end

      def por_obra
        estadisticas = @estadisticas_facade.obtener_estadisticas_por_obra(
          obra_id: params[:obra_id],
          periodo: params[:periodo]
        )

        render json: estadisticas, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Obra no encontrada" }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("ERROR ESTADISTICAS: #{e.message}")
        Rails.logger.error(e.backtrace.first(10).join("\n"))

        render json: { error: e.message }, status: :unprocessable_entity
      end

    end
  end
end