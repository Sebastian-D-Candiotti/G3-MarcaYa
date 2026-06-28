#app/application/facades/cronograma_facade.rb

# frozen_string_literal: true

module Api
  module V1
    class CronogramaController < BaseController
      before_action :require_empresa_or_admin!

      # POST /api/v1/cronograma/generar
      def generar
        resultado = cronograma_facade.generar(
          empleado_id: params[:empleado_id].to_i,
          obra_id:     params[:obra_id].to_i,
          periodo:     params[:periodo].to_s,
          tarifa_hora: params[:tarifa_hora].to_f
        )
        render json: cronograma_as_json(resultado), status: :created
      rescue ::Domain::Errors::ValidacionError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/cronograma/empleado/:empleado_id
      def por_empleado
        lista = cronograma_facade.listar_por_empleado(empleado_id: params[:empleado_id].to_i)
        render json: lista.map { |c| cronograma_as_json(c) }
      end

      # GET /api/v1/cronograma/obra/:obra_id
      def por_obra
        lista = cronograma_facade.listar_por_obra(obra_id: params[:obra_id].to_i)
        render json: lista.map { |c| cronograma_as_json(c) }
      end

      private

      def cronograma_facade
        Rails.configuration.di.cronograma_facade
      end

      def require_empresa_or_admin!
        unless ["empresa", "admin"].include?(current_user.rol)
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end

      def cronograma_as_json(c)
        {
          id:               c.id,
          empleado_id:      c.empleado_id,
          obra_id:          c.obra_id,
          periodo:          c.periodo,
          horas_trabajadas: c.horas_trabajadas,
          tarifa_hora:      c.tarifa_hora,
          monto_total:      c.monto_total,
          estado:           c.estado,
          created_at:       c.created_at
        }
      end
    end
  end
end
