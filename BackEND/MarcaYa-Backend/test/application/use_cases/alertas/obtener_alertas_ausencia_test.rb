# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../../app/domain/entities/alerta_ausencia"
require_relative "../../../../app/application/use_cases/alertas/obtener_alertas_ausencia"

module Application
  module UseCases
    module Alertas
      class ObtenerAlertasAusenciaTest < Minitest::Test
        def setup_fixtures; end
        def teardown_fixtures; end

        def test_devuelve_lista_vacia_cuando_no_hay_alertas
          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:listar_por_empresa_con_detalles) { |_empresa_id, estado:| [] }

          use_case = ObtenerAlertasAusencia.new(alerta_repo: alerta_repo)
          result = use_case.ejecutar(empresa_id: 1)

          assert_equal [], result
        end

        def test_devuelve_alertas_para_empresa
          alerta1 = { id: 1, empleado_id: 10, empleado_nombre: "Juan", obra_id: 1, obra_nombre: "Obra A", empresa_id: 1, fecha: Date.today, estado: "pendiente" }
          alerta2 = { id: 2, empleado_id: 20, empleado_nombre: "María", obra_id: 2, obra_nombre: "Obra B", empresa_id: 1, fecha: Date.today, estado: "pendiente" }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:listar_por_empresa_con_detalles) do |empresa_id, estado:|
            [alerta1, alerta2]
          end

          use_case = ObtenerAlertasAusencia.new(alerta_repo: alerta_repo)
          result = use_case.ejecutar(empresa_id: 1)

          assert_equal 2, result.length
          assert_equal 1, result[0][:id]
          assert_equal 2, result[1][:id]
        end

        def test_filtra_por_empresa_correctamente
          alerta_repo = Object.new
          empresa_recibida = nil
          alerta_repo.define_singleton_method(:listar_por_empresa_con_detalles) do |empresa_id, estado:|
            empresa_recibida = empresa_id
            []
          end

          use_case = ObtenerAlertasAusencia.new(alerta_repo: alerta_repo)
          use_case.ejecutar(empresa_id: 99)

          assert_equal 99, empresa_recibida
        end
      end
    end
  end
end
