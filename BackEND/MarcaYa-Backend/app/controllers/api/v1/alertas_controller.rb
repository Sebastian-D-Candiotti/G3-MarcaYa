# frozen_string_literal: true

module Api
  module V1
    class AlertasController < BaseController
      before_action :require_empresa_or_admin!, only: [:index, :resolver]

      # GET /api/v1/alertas/ausencias
      def index
        empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(current_user.id)
        empresa_id = empresa&.id
        alertas = alerta_ausencia_facade.listar_alertas(empresa_id)
        render json: Serializer::AlertaAusenciaSerializer.as_json_collection(alertas)
      end

      # PUT /api/v1/alertas/ausencias/:id/resolver
      def resolver
        alerta_ausencia_facade.resolver_alerta(params[:id])
        head :no_content
      rescue ::Domain::Errors::AlertaAusenciaNoEncontradaError => e
        render json: { error: e.message }, status: :not_found
      end

      # PUT /api/v1/alertas/ausencias/:id/desestimar
      def desestimar
        alerta_ausencia_facade.desestimar_alerta(params[:id])
        head :no_content
      rescue ::Domain::Errors::AlertaAusenciaNoEncontradaError => e
        render json: { error: e.message }, status: :not_found
      end

      private

      def require_empresa_or_admin!
        unless ["empresa", "admin"].include?(current_user.rol)
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end

      def alerta_ausencia_facade
        Rails.configuration.di.alerta_ausencia_facade
      end
    end
  end
end
