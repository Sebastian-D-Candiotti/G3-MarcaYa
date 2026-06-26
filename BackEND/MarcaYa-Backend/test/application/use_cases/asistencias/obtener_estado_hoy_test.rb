# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/application/use_cases/asistencias/obtener_estado_hoy"

module Application
  module UseCases
    module Asistencias
      class ObtenerEstadoHoyTest < Minitest::Test
        def test_devuelve_marcado_hoy_true_cuando_empleado_ya_registra_entrada
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_empleado_id| true }

          use_case = ObtenerEstadoHoy.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 1)

          assert_equal({ marcado_hoy: true }, result)
        end

        def test_devuelve_marcado_hoy_false_cuando_empleado_no_ha_marcado
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_empleado_id| false }

          use_case = ObtenerEstadoHoy.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 1)

          assert_equal({ marcado_hoy: false }, result)
        end

        def test_pasa_empleado_id_al_repositorio
          empleado_id_esperado = 42
          empleado_id_recibido = nil

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) do |eid|
            empleado_id_recibido = eid
            true
          end

          use_case = ObtenerEstadoHoy.new(asistencia_repo: asistencia_repo)
          use_case.ejecutar(empleado_id: empleado_id_esperado)

          assert_equal empleado_id_esperado, empleado_id_recibido
        end
      end
    end
  end
end
