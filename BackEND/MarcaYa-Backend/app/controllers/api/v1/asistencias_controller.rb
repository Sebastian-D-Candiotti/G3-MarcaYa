# frozen_string_literal: true

module Api
  module V1
    class AsistenciasController < BaseController
      before_action :require_empleado!, only: [:marcar_entrada, :marcar_salida, :historial_personal, :estado_hoy]
      before_action :require_empresa_or_admin!, only: [:historial_empleado, :tiempo_real, :tiempo_real_parada]

      # POST /api/v1/asistencia/marcar-entrada
      def marcar_entrada
        empleado = current_user.empleados.first
        render json: { error: "No se encontró empleado asociado" }, status: :not_found and return unless empleado

        resultado = asistencia_facade.marcar_entrada(
          empleado_id: empleado.id,
          parada_id: params[:parada_id],
          latitud: params[:latitud].to_f,
          longitud: params[:longitud].to_f,
          is_mocked: ActiveModel::Type::Boolean.new.cast(params[:is_mocked])
        )
        render json: Serializer::AsistenciaSerializer.as_json(resultado), status: :created
      rescue ::Domain::Errors::ValidacionError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ::Domain::Errors::AsistenciaNoEncontradaError => e
        render json: { error: e.message }, status: :not_found
      end

      # POST /api/v1/asistencia/marcar-salida
      def marcar_salida
        empleado = current_user.empleados.first
        render json: { error: "No se encontró empleado asociado" }, status: :not_found and return unless empleado

        resultado = asistencia_facade.marcar_salida(
          empleado_id: empleado.id,
          parada_id: params[:parada_id],
          latitud: params[:latitud].to_f,
          longitud: params[:longitud].to_f,
          is_mocked: ActiveModel::Type::Boolean.new.cast(params[:is_mocked])
        )
        render json: Serializer::AsistenciaSerializer.as_json(resultado), status: :created
      rescue ::Domain::Errors::ValidacionError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ::Domain::Errors::AsistenciaNoEncontradaError => e
        render json: { error: e.message }, status: :not_found
      end

      # GET /api/v1/asistencia/historial
      def historial_personal
        empleado = current_user.empleados.first
        render json: { error: "No se encontró empleado asociado" }, status: :not_found and return unless empleado

        registros = asistencia_facade.historial_personal(empleado_id: empleado.id)
        render json: registros.map { |r| Serializer::AsistenciaSerializer.as_json(r) }
      end

      # GET /api/v1/asistencia/historial/:empleado_id
      def historial_empleado
        registros = asistencia_facade.historial_empleado(empleado_id: params[:empleado_id])
        render json: registros.map { |r| Serializer::AsistenciaSerializer.as_json(r) }
      end

      # GET /api/v1/asistencia/tiempo-real
      def tiempo_real
        estados = asistencia_facade.tiempo_real
        render json: estados
      end

      # GET /api/v1/asistencia/tiempo-real/:parada_id
      def tiempo_real_parada
        estados = asistencia_facade.tiempo_real(parada_id: params[:parada_id])
        render json: estados
      end

      # GET /api/v1/asistencia/estado-hoy
      def estado_hoy
        empleado = current_user.empleados.first
        render json: { error: "No se encontró empleado asociado" }, status: :not_found and return unless empleado

        asignacion = empleado.asignaciones.first
        render json: { error: "Empleado sin obra asignada con horario" }, status: :not_found and return unless asignacion&.obra&.hora_inicio

        resultado = ::Application::UseCases::Asistencias::ObtenerEstadoHoy.new(
          asistencia_repo: Rails.configuration.di.repos[:asistencia]
        ).ejecutar(empleado_id: empleado.id)

        render json: resultado
      end

      private

      def asistencia_facade
        Rails.configuration.di.asistencia_facade
      end

      def require_empleado!
        unless current_user.rol == "empleado"
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end

      def require_empresa_or_admin!
        unless ["empresa", "admin"].include?(current_user.rol)
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end
    end
  end
end
