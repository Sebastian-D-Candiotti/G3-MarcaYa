# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/empleado_parada"
require_relative "../../../../app/domain/entities/asignacion"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/asignar_empleado"

module Application
  module UseCases
    module Paradas
      class AsignarEmpleadoTest < Minitest::Test
        def build_parada
          Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada", latitud: 0, longitud: 0
          )
        end

        def build_empleado
          Domain::Entities::Empleado.new(
            id: 5, usuario_id: 1, nombre: "Juan", apellido: "Perez"
          )
        end

        def build_asignacion_obra
          Domain::Entities::Asignacion.new(
            id: 1, empleado_id: 5, obra_id: 1, estado: "activo"
          )
        end

        def test_assigns_empleado_to_parada
          parada = build_parada
          empleado = build_empleado
          asignacion_obra = build_asignacion_obra

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [asignacion_obra] }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| nil }
          empleado_parada_repo.define_singleton_method(:guardar) { |ep| ep }

          use_case = AsignarEmpleado.new(
            parada_repo: parada_repo,
            empleado_repo: empleado_repo,
            empleado_parada_repo: empleado_parada_repo,
            asignacion_repo: asignacion_repo
          )

          result = use_case.ejecutar(parada_id: 10, empleado_id: 5)
          assert_instance_of Domain::Entities::EmpleadoParada, result
          assert_equal true, result.activo
        end

        def test_reactivates_inactive_assignment
          parada = build_parada
          empleado = build_empleado
          asignacion_obra = build_asignacion_obra
          asignacion_inactiva = Domain::Entities::EmpleadoParada.new(
            id: 99, empleado_id: 5, parada_id: 10, activo: false, estado: "inactivo"
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [asignacion_obra] }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion_inactiva }
          empleado_parada_repo.define_singleton_method(:guardar) { |ep| ep }

          use_case = AsignarEmpleado.new(
            parada_repo: parada_repo,
            empleado_repo: empleado_repo,
            empleado_parada_repo: empleado_parada_repo,
            asignacion_repo: asignacion_repo
          )

          result = use_case.ejecutar(parada_id: 10, empleado_id: 5)
          assert_equal true, result.activo
          assert_equal 99, result.id
        end

        def test_rejects_duplicate_active_assignment
          parada = build_parada
          empleado = build_empleado
          asignacion_obra = build_asignacion_obra
          asignacion_activa = Domain::Entities::EmpleadoParada.new(
            id: 99, empleado_id: 5, parada_id: 10, activo: true, estado: "activo"
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [asignacion_obra] }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion_activa }

          use_case = AsignarEmpleado.new(
            parada_repo: parada_repo,
            empleado_repo: empleado_repo,
            empleado_parada_repo: empleado_parada_repo,
            asignacion_repo: asignacion_repo
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(parada_id: 10, empleado_id: 5)
          end
        end

        def test_rejects_empleado_not_in_obra
          parada = build_parada
          empleado = build_empleado
          asignacion_otra_obra = Domain::Entities::Asignacion.new(
            id: 2, empleado_id: 5, obra_id: 99, estado: "activo"
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [asignacion_otra_obra] }

          empleado_parada_repo = Object.new

          use_case = AsignarEmpleado.new(
            parada_repo: parada_repo,
            empleado_repo: empleado_repo,
            empleado_parada_repo: empleado_parada_repo,
            asignacion_repo: asignacion_repo
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(parada_id: 10, empleado_id: 5)
          end
        end
      end
    end
  end
end
