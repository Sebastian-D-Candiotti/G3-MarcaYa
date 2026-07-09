# frozen_string_literal: true

module Api
  module V1
    class EstadisticasController < BaseController
      before_action :require_empresa_or_admin!

      # GET /api/v1/estadisticas/obra/:obra_id
      def por_obra
        resultado = estadisticas_facade.calcular_metricas_personal(
          obra_id: params[:obra_id].to_i,
          periodo: params[:periodo].to_s
        )

        render json: Serializer::EstadisticasSerializer.as_json(resultado)
      rescue ::Domain::Errors::ObraNoEncontradaError
        render json: { error: "Obra no encontrada" }, status: :not_found
      end

      private

      def estadisticas_facade
        Rails.configuration.di.estadisticas_facade
      end

      def require_empresa_or_admin!
        unless %w[empresa admin].include?(current_user.rol)
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end
    end
  end
end
