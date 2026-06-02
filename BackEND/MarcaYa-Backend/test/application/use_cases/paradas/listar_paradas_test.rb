# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/listar_paradas"

module Application
  module UseCases
    module Paradas
      class ListarParadasTest < Minitest::Test
        def test_returns_paradas_for_obra
          paradas = [
            Domain::Entities::Parada.new(id: 1, obra_id: 1, nombre: "P1", latitud: 0, longitud: 0),
            Domain::Entities::Parada.new(id: 2, obra_id: 1, nombre: "P2", latitud: 1, longitud: 1)
          ]

          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:listar_por_obra) { |_o| paradas }

          use_case = ListarParadas.new(parada_repo: parada_repo, obra_repo: obra_repo)
          result = use_case.ejecutar(obra_id: 1)

          assert_equal 2, result.size
          assert_equal "P1", result.first.nombre
        end

        def test_raises_when_obra_not_found
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ObraNoEncontradaError }

          parada_repo = Object.new

          use_case = ListarParadas.new(parada_repo: parada_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.ejecutar(obra_id: 999)
          end
        end

        def test_returns_empty_array_when_no_paradas
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:listar_por_obra) { |_o| [] }

          use_case = ListarParadas.new(parada_repo: parada_repo, obra_repo: obra_repo)
          result = use_case.ejecutar(obra_id: 1)

          assert_equal [], result
        end
      end
    end
  end
end
