# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/obras/eliminar_obra"

module Application
  module UseCases
    module Obras
      class EliminarObraTest < Minitest::Test
        def test_ejecutar_deletes_and_returns_true
          obra = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra a Eliminar",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00"
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| obra }
          repo.define_singleton_method(:eliminar) { |_o| true }

          use_case = EliminarObra.new(obra_repo: repo)
          result = use_case.ejecutar(id: 1)

          assert result
        end

        def test_ejecutar_raises_on_not_found
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::ObraNoEncontradaError
          end

          use_case = EliminarObra.new(obra_repo: repo)

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
