# frozen_string_literal: true

module Api
  module V1
    class ValoracionesController < BaseController
      before_action :authenticate_user!

      # POST /api/v1/valoraciones
      def crear
        empleado = current_user.empleados.first
        render json: { error: "No se encontró empleado asociado" }, status: :not_found and return unless empleado

        valoracion = valoracion_facade.crear_valoracion(
          empleado_id: empleado.id,
          empresa_id: params[:empresa_id],
          puntuacion: params[:puntuacion].to_i,
          comentario: params[:comentario]
        )
        render json: Serializer::ValoracionSerializer.as_json(valoracion), status: :created
      rescue Domain::Errors::PuntuacionInvalidaError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue Domain::Errors::EmpleadoNoEncontradoError => e
        render json: { error: e.message }, status: :not_found
      end

      # GET /api/v1/valoraciones/:usuario_id
      def listar
        valoraciones = valoracion_facade.listar_por_empresa(empresa_id: params[:usuario_id])
        render json: valoraciones.map { |v| Serializer::ValoracionSerializer.as_json(v) }
      end

      # GET /api/v1/valoraciones/:usuario_id/promedio
      def promedio
        promedio = valoracion_facade.promedio_empresa(empresa_id: params[:usuario_id])
        render json: promedio
      end

      private

      def valoracion_facade
        Rails.configuration.di.valoracion_facade
      end
    end
  end
end
