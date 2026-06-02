# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/eliminar_parada"

module Application
  module UseCases
    module Paradas
      class EliminarParadaTest < Minitest::Test
        def test_eliminar_returns_true
          parada = Domain::Entities::Parada.new(
            id: 1, obra_id: 1, nombre: "P", latitud: 0, longitud: 0
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }
          parada_repo.define_singleton_method(:eliminar) { |_p| true }

          use_case = EliminarParada.new(parada_repo: parada_repo)
          result = use_case.ejecutar(id: 1)

          assert_equal true, result
        end

        def test_raises_when_parada_not_found
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ParadaNoEncontradaError }

          use_case = EliminarParada.new(parada_repo: parada_repo)

          assert_raises Domain::Errors::ParadaNoEncontradaError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
