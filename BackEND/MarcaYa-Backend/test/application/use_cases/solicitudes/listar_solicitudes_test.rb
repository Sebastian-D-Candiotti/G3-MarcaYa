# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/solicitud"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/solicitudes/listar_solicitudes"

module Application
  module UseCases
    module Solicitudes
      class ListarSolicitudesTest < Minitest::Test
        def test_ejecutar_returns_all_solicitudes
          solicitudes = [
            Domain::Entities::Solicitud.new(id: 1, empleado_id: 1, empresa_id: 1),
            Domain::Entities::Solicitud.new(id: 2, empleado_id: 2, empresa_id: 1)
          ]

          repo = Object.new
          repo.define_singleton_method(:listar_pendientes) { solicitudes }

          use_case = ListarSolicitudes.new(solicitud_repo: repo)
          result = use_case.ejecutar

          assert_equal 2, result.length
          assert_equal solicitudes, result
        end

        def test_ejecutar_returns_empty_array_when_no_solicitudes
          repo = Object.new
          repo.define_singleton_method(:listar_pendientes) { [] }

          use_case = ListarSolicitudes.new(solicitud_repo: repo)
          result = use_case.ejecutar

          assert_equal [], result
          assert result.empty?
        end
      end
    end
  end
end
