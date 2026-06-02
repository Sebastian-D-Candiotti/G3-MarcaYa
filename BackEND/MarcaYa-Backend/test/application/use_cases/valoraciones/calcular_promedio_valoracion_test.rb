# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/valoracion"
require_relative "../../../../app/domain/services/valoracion_promedio_service"
require_relative "../../../../app/application/use_cases/valoraciones/calcular_promedio_valoracion"

module Application
  module UseCases
    module Valoraciones
      class CalcularPromedioValoracionTest < Minitest::Test
        def test_ejecutar_calcula_promedio
          valoraciones = [
            Domain::Entities::Valoracion.new(
              id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 5
            ),
            Domain::Entities::Valoracion.new(
              id: 2, empleado_id: 2, empresa_id: 1, puntuacion: 3
            )
          ]

          repo = Object.new
          repo.define_singleton_method(:listar_por_empresa) { |_eid| valoraciones }

          use_case = CalcularPromedioValoracion.new(valoracion_repo: repo)
          result = use_case.ejecutar(empresa_id: 1)

          assert_equal 4.0, result
        end

        def test_ejecutar_raises_on_empty_valoraciones
          repo = Object.new
          repo.define_singleton_method(:listar_por_empresa) { |_eid| [] }

          use_case = CalcularPromedioValoracion.new(valoracion_repo: repo)

          assert_raises ArgumentError do
            use_case.ejecutar(empresa_id: 1)
          end
        end
      end
    end
  end
end
