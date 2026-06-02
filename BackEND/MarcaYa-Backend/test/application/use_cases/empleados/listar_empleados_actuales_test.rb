# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/empleados/listar_empleados_actuales"

module Application
  module UseCases
    module Empleados
      class ListarEmpleadosActualesTest < Minitest::Test
        def test_ejecutar_returns_active_empleados
          activo = Domain::Entities::Empleado.new(
            id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez",
            estado: "activo"
          )
          inactivo = Domain::Entities::Empleado.new(
            id: 2, usuario_id: 2, nombre: "Pedro", apellido: "Gomez",
            estado: "inactivo"
          )

          repo = Object.new
          repo.define_singleton_method(:todos) { [activo, inactivo] }

          use_case = ListarEmpleadosActuales.new(empleado_repo: repo)
          result = use_case.ejecutar

          assert_equal 1, result.length
          assert result.all?(&:activo?)
        end

        def test_ejecutar_returns_empty_when_no_active_empleados
          repo = Object.new
          repo.define_singleton_method(:todos) { [] }

          use_case = ListarEmpleadosActuales.new(empleado_repo: repo)
          result = use_case.ejecutar

          assert_equal [], result
          assert result.empty?
        end
      end
    end
  end
end
