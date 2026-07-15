# frozen_string_literal: true

module Api
  module V1
    class ValoracionesController < BaseController
      # Se remueve before_action :authenticate_user! ya que se hereda :authenticate! de BaseController

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
        empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(params[:usuario_id])
        return render json: [] unless empresa

        valoraciones = valoracion_facade.listar_por_empresa(empresa_id: empresa.id)
        render json: valoraciones.map { |v| Serializer::ValoracionSerializer.as_json(v) }
      end

      # GET /api/v1/valoraciones/:usuario_id/promedio
      def promedio
        empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(params[:usuario_id])
        return render json: { promedio: 5.0, total: 0 } unless empresa

        valoraciones = Rails.configuration.di.repos[:valoracion].listar_por_empresa(empresa.id)
        
        promedio = if valoraciones.any?
                     Domain::Services::ValoracionPromedioService.calcular(valoraciones)
                   else
                     5.0
                   end
        
        render json: { promedio: promedio, total: valoraciones.size }
      end

      private

      def valoracion_facade
        Rails.configuration.di.valoracion_facade
      end
    end
  end
end
