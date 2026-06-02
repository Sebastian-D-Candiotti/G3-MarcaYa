# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/paradas/actualizar_parada"

module Application
  module UseCases
    module Paradas
      class ActualizarParadaTest < Minitest::Test
        def parada_existente
          Domain::Entities::Parada.new(
            id: 1, obra_id: 1, nombre: "Entrada Principal",
            latitud: -34.603722, longitud: -58.381592, radio_metros: 50, estado: "activa"
          )
        end

        def test_updates_parada_fields
          existente = parada_existente
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| existente }
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }
          parada_repo.define_singleton_method(:guardar) { |p| p }

          use_case = ActualizarParada.new(parada_repo: parada_repo)
          result = use_case.ejecutar(id: 1, params: { nombre: "Nueva Entrada", radio_metros: 100 })

          assert_equal "Nueva Entrada", result.nombre
          assert_equal 100, result.radio_metros
          assert_equal(-34.603722, result.latitud) # unchanged
        end

        def test_updates_estado
          existente = parada_existente
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| existente }
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }
          parada_repo.define_singleton_method(:guardar) { |p| p }

          use_case = ActualizarParada.new(parada_repo: parada_repo)
          result = use_case.ejecutar(id: 1, params: { estado: "inactiva" })

          assert_equal "inactiva", result.estado
        end

        def test_raises_on_duplicate_name
          existente = parada_existente
          otra_parada = Domain::Entities::Parada.new(
            id: 2, obra_id: 1, nombre: "Otra", latitud: 0, longitud: 0
          )

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| existente }
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| otra_parada }

          use_case = ActualizarParada.new(parada_repo: parada_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(id: 1, params: { nombre: "Otra" })
          end
        end

        def test_allows_same_name_without_conflict
          existente = parada_existente
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| existente }
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }
          parada_repo.define_singleton_method(:guardar) { |p| p }

          use_case = ActualizarParada.new(parada_repo: parada_repo)
          result = use_case.ejecutar(id: 1, params: { radio_metros: 75 })

          assert_equal 75, result.radio_metros
        end

        def test_raises_when_parada_not_found
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ParadaNoEncontradaError }

          use_case = ActualizarParada.new(parada_repo: parada_repo)

          assert_raises Domain::Errors::ParadaNoEncontradaError do
            use_case.ejecutar(id: 999, params: { nombre: "X" })
          end
        end

        def test_raises_on_invalid_coordinates
          existente = parada_existente
          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| existente }
          parada_repo.define_singleton_method(:buscar_por_nombre_y_obra) { |_n, _o| nil }

          use_case = ActualizarParada.new(parada_repo: parada_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(id: 1, params: { latitud: 95.0 })
          end
        end
      end
    end
  end
end
