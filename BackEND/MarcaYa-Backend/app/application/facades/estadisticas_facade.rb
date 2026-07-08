# frozen_string_literal: true

module Application
  module Facades
    class EstadisticasFacade
      def obtener_estadisticas_por_obra(obra_id:, periodo: nil)
        obra = ::Infrastructure::Orm::ObraRecord.find(obra_id)
        periodo ||= Date.today.strftime("%Y-%m")

        ::Application::UseCases::Estadisticas::CalcularMetricasPersonal.new(
          obra: obra,
          periodo: periodo
        ).call
      end
    end
  end
end