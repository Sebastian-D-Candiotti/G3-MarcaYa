# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/usuario"
require_relative "../../../app/domain/value_objects/rol_usuario"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/usuarios/obtener_usuario"
require_relative "../../../app/application/use_cases/usuarios/listar_usuarios"
require_relative "../../../app/application/use_cases/usuarios/actualizar_usuario"
require_relative "../../../app/application/use_cases/usuarios/desactivar_usuario"
require_relative "../../../app/application/facades/usuario_facade"

module Application
  module Facades
    class UsuarioFacadeTest < Minitest::Test
      def setup
        @usuario = Domain::Entities::Usuario.new(
          id: 1, correo: "test@test.com",
          clave_hash: "hash", rol: "empleado", estado: true
        )
        @usuarios = [@usuario]
      end

      def test_obtener_delegates_to_obtener_usuario
        usuario_snapshot = @usuario
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:find_by_id!) { |_| usuario_snapshot }
        usuario_repo.define_singleton_method(:todos) { [] }
        usuario_repo.define_singleton_method(:guardar) { |u| u }

        facade = UsuarioFacade.new(
          usuario_repo: usuario_repo
        )

        result = facade.obtener(id: 1)
        assert_equal usuario_snapshot, result
      end

      def test_listar_delegates_to_listar_usuarios
        usuarios_snapshot = @usuarios
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:todos) { usuarios_snapshot }

        facade = UsuarioFacade.new(
          usuario_repo: usuario_repo
        )

        result = facade.listar
        assert_equal 1, result.length
      end

      def test_actualizar_delegates_to_actualizar_usuario
          usuario_snapshot = Domain::Entities::Usuario.new(
            id: 1, correo: "viejo@test.com",
            clave_hash: "hash", rol: "empleado", estado: true
          )
          usuario_repo = Object.new
          usuario_repo.define_singleton_method(:find_by_id!) { |_| usuario_snapshot }
          usuario_repo.define_singleton_method(:guardar) { |u| u }

          facade = UsuarioFacade.new(
            usuario_repo: usuario_repo
          )

          result = facade.actualizar(id: 1, params: { correo: "nuevo@test.com" })
          assert_equal "nuevo@test.com", result.correo
        end

      def test_desactivar_delegates_to_desactivar_usuario
        usuario_activo = @usuario
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:find_by_id!) { |_| usuario_activo }
        usuario_repo.define_singleton_method(:guardar) do |u|
          Domain::Entities::Usuario.new(
            id: u.id, correo: u.correo,
            clave_hash: u.clave_hash, rol: u.rol.valor,
            estado: false
          )
        end

        facade = UsuarioFacade.new(
          usuario_repo: usuario_repo
        )

        result = facade.desactivar(id: 1)
        refute result.estado
      end
    end
  end
end
