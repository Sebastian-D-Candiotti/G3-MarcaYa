# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/empleado"
require_relative "../../../app/domain/entities/asignacion"
require_relative "../../../app/domain/entities/obra"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/empleados/obtener_obras_empleado"
require_relative "../../../app/application/use_cases/empleados/listar_empleados_actuales"
require_relative "../../../app/application/facades/empleado_facade"

module Application
  module Facades
    class EmpleadoFacadeTest < Minitest::Test
      def test_obtener_obras_delegates_to_obtener_obras_empleado
        empleado = Domain::Entities::Empleado.new(
          id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez"
        )
        obra = Domain::Entities::Obra.new(
          id: 1, empresa_id: 1, nombre: "Obra A",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )
        asignacion = Domain::Entities::Asignacion.new(
          id: 1, empleado_id: 1, obra_id: 1, estado: "activo"
        )

        empleado_repo = Object.new
        empleado_repo.define_singleton_method(:find_by_id!) { |_| empleado }
        empleado_repo.define_singleton_method(:todos) { [empleado] }

        asignacion_repo = Object.new
        asignacion_repo.define_singleton_method(:listar_por_empleado) { |_| [asignacion] }

        obra_repo = Object.new
        obra_repo.define_singleton_method(:find_by_id!) { |_| obra }

        facade = EmpleadoFacade.new(
          empleado_repo: empleado_repo,
          asignacion_repo: asignacion_repo,
          obra_repo: obra_repo
        )
        result = facade.obtener_obras(empleado_id: 1)

        assert_equal 1, result.length
        assert_equal obra, result.first
      end

      def test_listar_actuales_delegates_to_listar_empleados_actuales
        empleado = Domain::Entities::Empleado.new(
          id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez",
          estado: "activo"
        )

        empleado_repo = Object.new
        empleado_repo.define_singleton_method(:todos) { [empleado] }
        empleado_repo.define_singleton_method(:find_by_id!) { |_| empleado }

        asignacion_repo = Object.new
        obra_repo = Object.new

        facade = EmpleadoFacade.new(
          empleado_repo: empleado_repo,
          asignacion_repo: asignacion_repo,
          obra_repo: obra_repo
        )
        result = facade.listar_actuales

        assert_equal 1, result.length
        assert result.first.activo?
      end
    end
  end
end
