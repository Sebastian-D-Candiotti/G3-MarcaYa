# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/obras/crear_obra"

module Application
  module UseCases
    module Obras
      class CrearObraTest < Minitest::Test
        def test_ejecutar_creates_and_returns_obra
          params = {
            empresa_id: 1, nombre: "Nueva Obra",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00",
            direccion: "Av. Principal 123"
          }

          obra_creada = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Nueva Obra",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: "08:00", hora_fin: "17:00",
            direccion: "Av. Principal 123"
          )

          repo = Object.new
          repo.define_singleton_method(:guardar) { |_o| obra_creada }

          use_case = CrearObra.new(obra_repo: repo)
          result = use_case.ejecutar(params)

          assert_equal obra_creada, result
          assert_equal "Nueva Obra", result.nombre
        end

        def test_ejecutar_validates_required_fields
          repo = Object.new

          use_case = CrearObra.new(obra_repo: repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar({ nombre: "Incompleta" })
          end
        end

        def test_ejecutar_validates_empty_required_fields
          repo = Object.new

          use_case = CrearObra.new(obra_repo: repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              empresa_id: 1, nombre: "", latitud: -12.0,
              longitud: -77.0, hora_inicio: "08:00", hora_fin: ""
            )
          end
        end
      end
    end
  end
end
