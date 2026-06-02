# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/obras/obtener_obra"

module Application
  module UseCases
    module Obras
      class ObtenerObraTest < Minitest::Test
        def test_ejecutar_returns_obra
          obra = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra Test",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00"
          )
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| obra }

          use_case = ObtenerObra.new(obra_repo: repo)
          result = use_case.ejecutar(id: 1)

          assert_equal obra, result
        end

        def test_ejecutar_raises_obra_no_encontrada
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::ObraNoEncontradaError
          end

          use_case = ObtenerObra.new(obra_repo: repo)

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
