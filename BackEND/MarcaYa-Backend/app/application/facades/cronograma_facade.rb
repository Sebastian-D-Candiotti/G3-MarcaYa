#app/application/facades/cronograma_facade.rb

# frozen_string_literal: true

module Application
  module Facades
    class CronogramaFacade
      def initialize(asistencia_repo:, cronograma_repo:)
        @asistencia_repo = asistencia_repo
        @cronograma_repo = cronograma_repo
      end

      def generar(empleado_id:, obra_id:, periodo:, tarifa_hora:)
        UseCases::Cronograma::GenerarCronograma.new(
          asistencia_repo: @asistencia_repo,
          cronograma_repo: @cronograma_repo
        ).ejecutar(
          empleado_id: empleado_id,
          obra_id:     obra_id,
          periodo:     periodo,
          tarifa_hora: tarifa_hora
        )
      end

      def listar_por_empleado(empleado_id:)
        @cronograma_repo.listar_por_empleado(empleado_id)
      end

      def listar_por_obra(obra_id:)
        @cronograma_repo.listar_por_obra(obra_id)
      end
    end
  end
end
