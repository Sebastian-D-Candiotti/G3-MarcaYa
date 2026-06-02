# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/crear_parada"

module Application
  module UseCases
    module Paradas
      class CrearParadaTest < Minitest::Test
        def test_creates_parada_with_valid_data
          parada_creada = Domain::Entities::Parada.new(
            id: 1, obra_id: 1, nombre: "Entrada Principal",
            latitud: -34.603722, longitud: -58.381592, radio_metros: 50, estado: "activa"
          )

          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }
          parada_repo.define_singleton_method(:guardar) { |_p| parada_creada }

          use_case = CrearParada.new(parada_repo: parada_repo, obra_repo: obra_repo)
          result = use_case.ejecutar(obra_id: 1, params: {
            nombre: "Entrada Principal",
            latitud: -34.603722,
            longitud: -58.381592,
            radio_metros: 50
          })

          assert_equal parada_creada, result
          assert_equal "Entrada Principal", result.nombre
        end

        def test_raises_when_obra_not_found
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ObraNoEncontradaError }

          parada_repo = Object.new

          use_case = CrearParada.new(parada_repo: parada_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.ejecutar(obra_id: 999, params: { nombre: "X", latitud: 0, longitud: 0 })
          end
        end

        def test_raises_on_duplicate_name_in_same_obra
          existente = Domain::Entities::Parada.new(
            id: 1, obra_id: 1, nombre: "Entrada Principal",
            latitud: -34.603722, longitud: -58.381592
          )

          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| existente }

          use_case = CrearParada.new(parada_repo: parada_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(obra_id: 1, params: {
              nombre: "Entrada Principal",
              latitud: -34.603722,
              longitud: -58.381592
            })
          end
        end

        def test_raises_on_invalid_coordinates
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }

          use_case = CrearParada.new(parada_repo: parada_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(obra_id: 1, params: {
              nombre: "Mala",
              latitud: 95.0,
              longitud: -58.38
            })
          end
        end

        def test_raises_on_invalid_radio
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) { |_id| true }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }

          use_case = CrearParada.new(parada_repo: parada_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(obra_id: 1, params: {
              nombre: "Mala",
              latitud: -34.0,
              longitud: -58.0,
              radio_metros: 0
            })
          end
        end
      end
    end
  end
end
