# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/solicitud"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/solicitudes/crear_solicitud"

module Application
  module UseCases
    module Solicitudes
      class CrearSolicitudTest < Minitest::Test
        def test_ejecutar_creates_and_returns_solicitud
          solicitud_creada = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1
          )

          repo = Object.new
          repo.define_singleton_method(:listar_por_empleado) { |_eid| [] }
          repo.define_singleton_method(:guardar) { |_s| solicitud_creada }

          use_case = CrearSolicitud.new(solicitud_repo: repo)
          result = use_case.ejecutar(empleado_id: 1, empresa_id: 1)

          assert_equal solicitud_creada, result
          assert_equal 1, result.empleado_id
          assert_equal 1, result.empresa_id
        end

        def test_ejecutar_raises_on_duplicate_pending_for_same_empresa
          pending = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "pendiente"
          )

          repo = Object.new
          repo.define_singleton_method(:listar_por_empleado) { |_eid| [pending] }

          use_case = CrearSolicitud.new(solicitud_repo: repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(empleado_id: 1, empresa_id: 1)
          end
        end

        def test_ejecutar_allows_pending_for_different_empresa
          pending = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "pendiente"
          )
          solicitud_nueva = Domain::Entities::Solicitud.new(
            id: 2, empleado_id: 1, empresa_id: 2
          )

          repo = Object.new
          repo.define_singleton_method(:listar_por_empleado) { |_eid| [pending] }
          repo.define_singleton_method(:guardar) { |_s| solicitud_nueva }

          use_case = CrearSolicitud.new(solicitud_repo: repo)
          result = use_case.ejecutar(empleado_id: 1, empresa_id: 2)

          assert_equal solicitud_nueva, result
        end

        def test_ejecutar_fails_if_previous_solicitud_aceptada
          aceptada = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "aceptada"
          )

          repo = Object.new
          repo.define_singleton_method(:listar_por_empleado) { |_eid| [aceptada] }

          use_case = CrearSolicitud.new(solicitud_repo: repo)
          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(empleado_id: 1, empresa_id: 1)
          end
        end
      end
    end
  end
end
