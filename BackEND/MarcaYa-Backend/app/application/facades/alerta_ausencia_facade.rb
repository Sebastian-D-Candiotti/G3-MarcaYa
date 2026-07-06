# frozen_string_literal: true

module Application
  module Facades
    class AlertaAusenciaFacade
      def initialize(alerta_repo:, obra_repo:, asistencia_repo:)
        @alerta_repo = alerta_repo
        @obra_repo = obra_repo
        @asistencia_repo = asistencia_repo
      end

      def evaluar_ausencias
        UseCases::Alertas::EvaluarAusencias.new(
          alerta_repo: @alerta_repo,
          obra_repo: @obra_repo,
          asistencia_repo: @asistencia_repo
        ).ejecutar
      end

      def listar_alertas(empresa_id)
        UseCases::Alertas::ObtenerAlertasAusencia.new(
          alerta_repo: @alerta_repo
        ).ejecutar(empresa_id: empresa_id)
      end

      def resolver_alerta(id)
        UseCases::Alertas::ResolverAlerta.new(
          alerta_repo: @alerta_repo
        ).ejecutar(id: id, estado: "resuelta")
      end

      def desestimar_alerta(id)
        UseCases::Alertas::ResolverAlerta.new(
          alerta_repo: @alerta_repo
        ).ejecutar(id: id, estado: "desestimada")
      end
    end
  end
end
