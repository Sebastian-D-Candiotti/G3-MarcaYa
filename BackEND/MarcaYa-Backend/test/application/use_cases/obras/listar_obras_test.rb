# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/obras/listar_obras"

module Application
  module UseCases
    module Obras
      class ListarObrasTest < Minitest::Test
        def test_ejecutar_returns_all_obras
          obras = [
            Domain::Entities::Obra.new(
              id: 1, empresa_id: 1, nombre: "Obra A",
              latitud: -12.0, longitud: -77.0,
              hora_inicio: "08:00", hora_fin: "17:00"
            ),
            Domain::Entities::Obra.new(
              id: 2, empresa_id: 1, nombre: "Obra B",
              latitud: -12.1, longitud: -77.1,
              hora_inicio: "09:00", hora_fin: "18:00"
            )
          ]

          repo = Object.new
          repo.define_singleton_method(:todos) { obras }

          use_case = ListarObras.new(obra_repo: repo)
          result = use_case.ejecutar

          assert_equal 2, result.length
          assert_equal obras, result
        end

        def test_ejecutar_returns_empty_array_when_no_obras
          repo = Object.new
          repo.define_singleton_method(:todos) { [] }

          use_case = ListarObras.new(obra_repo: repo)
          result = use_case.ejecutar

          assert_equal [], result
          assert result.empty?
        end
      end
    end
  end
end
