# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/obras/actualizar_obra"

module Application
  module UseCases
    module Obras
      class ActualizarObraTest < Minitest::Test
        def test_ejecutar_updates_and_returns_obra
          obra_existente = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra Vieja",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00",
            direccion: "Av. Vieja 123"
          )
          obra_actualizada = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra Actualizada",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00",
            direccion: "Av. Nueva 456"
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| obra_existente }
          repo.define_singleton_method(:guardar) { |_o| obra_actualizada }

          use_case = ActualizarObra.new(obra_repo: repo)
          result = use_case.ejecutar(
            id: 1, params: { nombre: "Obra Actualizada", direccion: "Av. Nueva 456" }
          )

          assert_equal "Obra Actualizada", result.nombre
          assert_equal "Av. Nueva 456", result.direccion
        end

        def test_ejecutar_raises_on_not_found
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::ObraNoEncontradaError
          end

          use_case = ActualizarObra.new(obra_repo: repo)

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.ejecutar(id: 999, params: { nombre: "X" })
          end
        end
      end
    end
  end
end
