# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/asignacion"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/empleados/obtener_obras_empleado"

module Application
  module UseCases
    module Empleados
      class ObtenerObrasEmpleadoTest < Minitest::Test
        def test_ejecutar_returns_obras_from_active_assignments
          empleado = Domain::Entities::Empleado.new(
            id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez"
          )
          obra = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra A",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00"
          )
          asignacion_activa = Domain::Entities::Asignacion.new(
            id: 1, empleado_id: 1, obra_id: 1, estado: "activo"
          )

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [asignacion_activa] }

          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| obra }

          use_case = ObtenerObrasEmpleado.new(
            empleado_repo: empleado_repo,
            asignacion_repo: asignacion_repo,
            obra_repo: obra_repo
          )
          result = use_case.ejecutar(empleado_id: 1)

          assert_equal 1, result.length
          assert_equal obra, result.first
        end

        def test_ejecutar_filters_out_inactive_assignments
          empleado = Domain::Entities::Empleado.new(
            id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez"
          )
          obra = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra A",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00"
          )
          inactiva = Domain::Entities::Asignacion.new(
            id: 1, empleado_id: 1, obra_id: 1, estado: "inactivo"
          )

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:listar_por_empleado) { |_eid| [inactiva] }

          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| obra }

          use_case = ObtenerObrasEmpleado.new(
            empleado_repo: empleado_repo,
            asignacion_repo: asignacion_repo,
            obra_repo: obra_repo
          )
          result = use_case.ejecutar(empleado_id: 1)

          assert_equal 0, result.length
          assert result.empty?
        end

        def test_ejecutar_raises_on_empleado_not_found
          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) do |_id|
            raise StandardError, "Empleado no encontrado"
          end

          use_case = ObtenerObrasEmpleado.new(
            empleado_repo: empleado_repo,
            asignacion_repo: Object.new,
            obra_repo: Object.new
          )

          assert_raises StandardError do
            use_case.ejecutar(empleado_id: 999)
          end
        end
      end
    end
  end
end
