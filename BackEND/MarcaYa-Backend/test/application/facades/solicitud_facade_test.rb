# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/solicitud"
require_relative "../../../app/domain/entities/asignacion"
require_relative "../../../app/domain/entities/obra"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/solicitudes/listar_solicitudes"
require_relative "../../../app/application/use_cases/solicitudes/crear_solicitud"
require_relative "../../../app/application/use_cases/solicitudes/aceptar_solicitud"
require_relative "../../../app/application/use_cases/solicitudes/rechazar_solicitud"
require_relative "../../../app/application/use_cases/asignaciones/crear_asignacion"
require_relative "../../../app/application/facades/solicitud_facade"

module Application
  module Facades
    class SolicitudFacadeTest < Minitest::Test
      def setup
        @solicitud = Domain::Entities::Solicitud.new(
          id: 1, empleado_id: 1, empresa_id: 1
        )
        @solicitud_repo = Object.new
        @asignacion_repo = Object.new
        @asignacion_repo.define_singleton_method(:listar_por_empleado) { |_| [] }
        @obra_repo = Object.new
        @obra_repo.define_singleton_method(:listar_por_empresa) { |_| [] }
      end

      def test_listar_delegates_to_listar_solicitudes
        solicitud_snapshot = @solicitud
        @solicitud_repo.define_singleton_method(:listar_pendientes) { [solicitud_snapshot] }

        facade = SolicitudFacade.new(
          solicitud_repo: @solicitud_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        )
        result = facade.listar

        assert_equal 1, result.length
      end

      def test_crear_delegates_to_crear_solicitud
        solicitud_snapshot = @solicitud
        @solicitud_repo.define_singleton_method(:listar_por_empleado) { |_| [] }
        @solicitud_repo.define_singleton_method(:guardar) { |_| solicitud_snapshot }

        facade = SolicitudFacade.new(
          solicitud_repo: @solicitud_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        )
        result = facade.crear(empleado_id: 1, empresa_id: 1)

        assert_equal solicitud_snapshot, result
      end

      def test_aceptar_orchestrates_solicitud_acceptance_and_asignacion_creation
        pendiente = Domain::Entities::Solicitud.new(
          id: 1, empleado_id: 1, empresa_id: 1, estado: "pendiente"
        )
        aceptada = Domain::Entities::Solicitud.new(
          id: 1, empleado_id: 1, empresa_id: 1, estado: "aceptada"
        )
        obra = Domain::Entities::Obra.new(
          id: 2, empresa_id: 1, nombre: "Obra A",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )
        asignacion_guardada = Domain::Entities::Asignacion.new(
          id: 5, empleado_id: 1, obra_id: 2, estado: "activo"
        )

        @solicitud_repo.define_singleton_method(:find_by_id!) { |_| pendiente }
        @solicitud_repo.define_singleton_method(:guardar) { |_| aceptada }
        @obra_repo.define_singleton_method(:find_by_id!) { |_| obra }

        asignacion_saved = false
        @asignacion_repo.define_singleton_method(:guardar) do |asignacion|
          asignacion_saved = true
          asignacion_guardada
        end

        facade = SolicitudFacade.new(
          solicitud_repo: @solicitud_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        )
        result = facade.aceptar(id: 1, obra_id: 2)

        assert result.aceptada?
        assert asignacion_saved
      end

      def test_rechazar_delegates_to_rechazar_solicitud
        pendiente = Domain::Entities::Solicitud.new(
          id: 1, empleado_id: 1, empresa_id: 1, estado: "pendiente"
        )
        rechazada = Domain::Entities::Solicitud.new(
          id: 1, empleado_id: 1, empresa_id: 1, estado: "rechazada"
        )
        @solicitud_repo.define_singleton_method(:find_by_id!) { |_| pendiente }
        @solicitud_repo.define_singleton_method(:guardar) { |_| rechazada }

        facade = SolicitudFacade.new(
          solicitud_repo: @solicitud_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        )
        result = facade.rechazar(id: 1)

        assert result.rechazada?
      end
    end
  end
end
