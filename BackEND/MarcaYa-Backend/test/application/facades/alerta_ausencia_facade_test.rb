# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../app/domain/entities/obra"
require_relative "../../../app/domain/entities/asignacion"
require_relative "../../../app/domain/entities/alerta_ausencia"
require_relative "../../../app/application/use_cases/alertas/evaluar_ausencias"
require_relative "../../../app/application/use_cases/alertas/obtener_alertas_ausencia"
require_relative "../../../app/application/use_cases/alertas/resolver_alerta"
require_relative "../../../app/application/facades/alerta_ausencia_facade"

module Application
  module Facades
    class AlertaAusenciaFacadeTest < Minitest::Test
      def setup_fixtures; end
      def teardown_fixtures; end

      def test_evaluar_ausencias_delega_al_use_case
        alerta_repo = Object.new
        obra_repo = Object.new
        obra_repo.define_singleton_method(:listar_activas_con_asignaciones) { [] }
        asistencia_repo = Object.new

        facade = AlertaAusenciaFacade.new(
          alerta_repo: alerta_repo,
          obra_repo: obra_repo,
          asistencia_repo: asistencia_repo
        )

        result = facade.evaluar_ausencias

        assert_equal({ evaluadas: 0, creadas: 0, resueltas: 0 }, result)
      end

      def test_listar_alertas_usa_repo_con_detalles
        alerta_repo = Object.new
        alerta_repo.define_singleton_method(:listar_por_empresa_con_detalles) do |empresa_id, estado:|
          [{ id: 1, empleado_nombre: "Juan" }]
        end
        obra_repo = Object.new
        asistencia_repo = Object.new

        facade = AlertaAusenciaFacade.new(
          alerta_repo: alerta_repo,
          obra_repo: obra_repo,
          asistencia_repo: asistencia_repo
        )

        result = facade.listar_alertas(99)

        assert_equal 1, result.length
        assert_equal "Juan", result[0][:empleado_nombre]
      end

      def test_resolver_alerta_delega_al_use_case_con_estado_resuelta
        llamado_con = []
        alerta_repo = Object.new
        alerta_repo.define_singleton_method(:actualizar_estado) do |id, estado|
          llamado_con << { id: id, estado: estado }
        end
        obra_repo = Object.new
        asistencia_repo = Object.new

        facade = AlertaAusenciaFacade.new(
          alerta_repo: alerta_repo,
          obra_repo: obra_repo,
          asistencia_repo: asistencia_repo
        )

        facade.resolver_alerta(42)

        assert_equal 1, llamado_con.length
        assert_equal 42, llamado_con[0][:id]
        assert_equal "resuelta", llamado_con[0][:estado]
      end

      def test_desestimar_alerta_delega_al_use_case_con_estado_desestimada
        llamado_con = []
        alerta_repo = Object.new
        alerta_repo.define_singleton_method(:actualizar_estado) do |id, estado|
          llamado_con << { id: id, estado: estado }
        end
        obra_repo = Object.new
        asistencia_repo = Object.new

        facade = AlertaAusenciaFacade.new(
          alerta_repo: alerta_repo,
          obra_repo: obra_repo,
          asistencia_repo: asistencia_repo
        )

        facade.desestimar_alerta(7)

        assert_equal 1, llamado_con.length
        assert_equal 7, llamado_con[0][:id]
        assert_equal "desestimada", llamado_con[0][:estado]
      end
    end
  end
end
