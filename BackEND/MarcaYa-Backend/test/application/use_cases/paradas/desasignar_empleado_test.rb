# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado_parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/desasignar_empleado"

module Application
  module UseCases
    module Paradas
      class DesasignarEmpleadoTest < Minitest::Test
        def setup
          @parada = Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada", latitud: 0, longitud: 0
          )
        end

        def test_desasignar_sets_inactive
          asignacion = Domain::Entities::EmpleadoParada.new(
            id: 99, empleado_id: 5, parada_id: 10, activo: true, estado: "activo"
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| @parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }
          empleado_parada_repo.define_singleton_method(:guardar) { |ep| ep }

          use_case = DesasignarEmpleado.new(parada_repo: parada_repo, empleado_parada_repo: empleado_parada_repo)
          result = use_case.ejecutar(parada_id: 10, empleado_id: 5)

          assert_equal true, result
        end

        def test_returns_true_when_no_assignment_exists
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| @parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| nil }

          use_case = DesasignarEmpleado.new(parada_repo: parada_repo, empleado_parada_repo: empleado_parada_repo)
          result = use_case.ejecutar(parada_id: 10, empleado_id: 5)

          assert_equal true, result
        end

        def test_returns_true_when_assignment_already_inactive
          asignacion_inactiva = Domain::Entities::EmpleadoParada.new(
            id: 99, empleado_id: 5, parada_id: 10, activo: false, estado: "inactivo"
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| @parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion_inactiva }

          use_case = DesasignarEmpleado.new(parada_repo: parada_repo, empleado_parada_repo: empleado_parada_repo)
          result = use_case.ejecutar(parada_id: 10, empleado_id: 5)

          assert_equal true, result
        end

        def test_raises_when_parada_not_found
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ParadaNoEncontradaError }

          use_case = DesasignarEmpleado.new(parada_repo: parada_repo, empleado_parada_repo: nil)

          assert_raises Domain::Errors::ParadaNoEncontradaError do
            use_case.ejecutar(parada_id: 999, empleado_id: 5)
          end
        end
      end
    end
  end
end
