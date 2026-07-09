# frozen_string_literal: true

module Application
  module Facades
    class EstadisticasFacade
      def initialize(obra_repo:, parada_repo:, asistencia_repo:, empleado_repo:, empleado_parada_repo:)
        @obra_repo = obra_repo
        @parada_repo = parada_repo
        @asistencia_repo = asistencia_repo
        @empleado_repo = empleado_repo
        @empleado_parada_repo = empleado_parada_repo
      end

      def calcular_metricas_personal(obra_id:, periodo:)
        UseCases::Estadisticas::CalcularMetricasPersonal.new(
          obra_repo: @obra_repo,
          parada_repo: @parada_repo,
          asistencia_repo: @asistencia_repo,
          empleado_repo: @empleado_repo,
          empleado_parada_repo: @empleado_parada_repo
        ).call(obra_id: obra_id, periodo: periodo)
      end
    end
  end
end
