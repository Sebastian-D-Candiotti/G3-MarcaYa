# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/valoracion"
require_relative "../../../../app/application/use_cases/valoraciones/listar_valoraciones_empresa"

module Application
  module UseCases
    module Valoraciones
      class ListarValoracionesEmpresaTest < Minitest::Test
        def test_ejecutar_returns_valoraciones
          valoraciones = [
            Domain::Entities::Valoracion.new(
              id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 5,
              comentario: "Excelente"
            ),
            Domain::Entities::Valoracion.new(
              id: 2, empleado_id: 2, empresa_id: 1, puntuacion: 4,
              comentario: "Buena"
            )
          ]

          repo = Object.new
          repo.define_singleton_method(:listar_por_empresa) { |_eid| valoraciones }

          use_case = ListarValoracionesEmpresa.new(valoracion_repo: repo)
          result = use_case.ejecutar(empresa_id: 1)

          assert_equal 2, result.length
          assert_equal valoraciones, result
        end

        def test_ejecutar_returns_empty_when_no_valoraciones
          repo = Object.new
          repo.define_singleton_method(:listar_por_empresa) { |_eid| [] }

          use_case = ListarValoracionesEmpresa.new(valoracion_repo: repo)
          result = use_case.ejecutar(empresa_id: 1)

          assert_equal [], result
          assert result.empty?
        end
      end
    end
  end
end
