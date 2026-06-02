# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/obra"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/obras/listar_obras"
require_relative "../../../app/application/use_cases/obras/obtener_obra"
require_relative "../../../app/application/use_cases/obras/crear_obra"
require_relative "../../../app/application/use_cases/obras/actualizar_obra"
require_relative "../../../app/application/use_cases/obras/eliminar_obra"
require_relative "../../../app/application/facades/obra_facade"

module Application
  module Facades
    class ObraFacadeTest < Minitest::Test
      def setup
        @obra = Domain::Entities::Obra.new(
          id: 1, empresa_id: 1, nombre: "Obra Test",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )
        @obras = [@obra]
      end

      def test_listar_delegates_to_listar_obras
        obras_snapshot = @obras
        repo = Object.new
        repo.define_singleton_method(:todos) { obras_snapshot }

        facade = ObraFacade.new(obra_repo: repo)
        result = facade.listar

        assert_equal 1, result.length
        assert_equal obras_snapshot, result
      end

      def test_obtener_delegates_to_obtener_obra
        obra_snapshot = @obra
        repo = Object.new
        repo.define_singleton_method(:find_by_id!) { |_| obra_snapshot }

        facade = ObraFacade.new(obra_repo: repo)
        result = facade.obtener(id: 1)

        assert_equal obra_snapshot, result
      end

      def test_crear_delegates_to_crear_obra
        obra_snapshot = @obra
        repo = Object.new
        repo.define_singleton_method(:guardar) { |_| obra_snapshot }

        facade = ObraFacade.new(obra_repo: repo)
        result = facade.crear(
          empresa_id: 1, nombre: "Obra Test",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )

        assert_equal obra_snapshot, result
      end

      def test_actualizar_delegates_to_actualizar_obra
        obra_existente = Domain::Entities::Obra.new(
          id: 1, empresa_id: 1, nombre: "Vieja",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )
        obra_actualizada = Domain::Entities::Obra.new(
          id: 1, empresa_id: 1, nombre: "Actualizada",
          latitud: -12.0, longitud: -77.0,
          hora_inicio: "08:00", hora_fin: "17:00"
        )
        repo = Object.new
        repo.define_singleton_method(:find_by_id!) { |_| obra_existente }
        repo.define_singleton_method(:guardar) { |_| obra_actualizada }

        facade = ObraFacade.new(obra_repo: repo)
        result = facade.actualizar(id: 1, params: { nombre: "Actualizada" })

        assert_equal "Actualizada", result.nombre
      end

      def test_eliminar_delegates_to_eliminar_obra
        repo = Object.new
        repo.define_singleton_method(:find_by_id!) { |_| @obra }
        repo.define_singleton_method(:eliminar) { |_| true }

        facade = ObraFacade.new(obra_repo: repo)
        result = facade.eliminar(id: 1)

        assert result
      end
    end
  end
end
