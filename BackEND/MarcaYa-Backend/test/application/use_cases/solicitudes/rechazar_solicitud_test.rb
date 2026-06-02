# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/solicitud"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/solicitudes/rechazar_solicitud"

module Application
  module UseCases
    module Solicitudes
      class RechazarSolicitudTest < Minitest::Test
        def test_ejecutar_rechaza_solicitud
          solicitud = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "pendiente"
          )
          solicitud_rechazada = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "rechazada"
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| solicitud }
          repo.define_singleton_method(:guardar) { |_s| solicitud_rechazada }

          use_case = RechazarSolicitud.new(solicitud_repo: repo)
          result = use_case.ejecutar(id: 1)

          assert result.rechazada?
        end

        def test_ejecutar_raises_on_invalid_transition
          solicitud = Domain::Entities::Solicitud.new(
            id: 1, empleado_id: 1, empresa_id: 1, estado: "rechazada"
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| solicitud }

          use_case = RechazarSolicitud.new(solicitud_repo: repo)

          assert_raises Domain::Errors::TransicionEstadoInvalidaError do
            use_case.ejecutar(id: 1)
          end
        end
      end
    end
  end
end
