# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/empleado_parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/listar_empleados_parada"

module Application
  module UseCases
    module Paradas
      class ListarEmpleadosParadaTest < Minitest::Test
        def test_returns_employees_for_parada
          parada = Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada", latitud: 0, longitud: 0
          )
          empleado = Domain::Entities::Empleado.new(
            id: 5, usuario_id: 1, nombre: "Juan", apellido: "Perez"
          )
          asignacion = Domain::Entities::EmpleadoParada.new(
            id: 1, empleado_id: 5, parada_id: 10, activo: true
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:listar_activos_por_parada) { |_pid| [asignacion] }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          use_case = ListarEmpleadosParada.new(
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            empleado_repo: empleado_repo
          )

          result = use_case.ejecutar(parada_id: 10)
          assert_equal 1, result.size
          assert_equal "Juan", result.first.nombre
        end

        def test_returns_empty_when_no_active_assignments
          parada = Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada", latitud: 0, longitud: 0
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:listar_activos_por_parada) { |_pid| [] }

          empleado_repo = Object.new

          use_case = ListarEmpleadosParada.new(
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            empleado_repo: empleado_repo
          )

          result = use_case.ejecutar(parada_id: 10)
          assert_equal [], result
        end

        def test_raises_when_parada_not_found
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ParadaNoEncontradaError }

          use_case = ListarEmpleadosParada.new(
            parada_repo: parada_repo,
            empleado_parada_repo: nil,
            empleado_repo: nil
          )

          assert_raises Domain::Errors::ParadaNoEncontradaError do
            use_case.ejecutar(parada_id: 999)
          end
        end
      end
    end
  end
end
