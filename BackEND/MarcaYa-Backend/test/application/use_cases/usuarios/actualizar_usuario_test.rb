# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/usuarios/actualizar_usuario"

module Application
  module UseCases
    module Usuarios
      class ActualizarUsuarioTest < Minitest::Test
        def test_ejecutar_updates_and_returns_usuario
          usuario_existente = Domain::Entities::Usuario.new(
            id: 1, correo: "viejo@test.com",
            clave_hash: "hash", rol: "empleado", estado: true
          )
          usuario_actualizado = Domain::Entities::Usuario.new(
            id: 1, correo: "nuevo@test.com",
            clave_hash: "hash", rol: "empleado", estado: true
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| usuario_existente }
          repo.define_singleton_method(:guardar) { |_u| usuario_actualizado }

          use_case = ActualizarUsuario.new(usuario_repo: repo)
          result = use_case.ejecutar(
            id: 1,
            params: { correo: "nuevo@test.com", nombre: "Juan" }
          )

          assert_equal "nuevo@test.com", result.correo
          assert_equal 1, result.id
        end

        def test_ejecutar_raises_usuario_no_encontrado
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::UsuarioNoEncontradoError
          end

          use_case = ActualizarUsuario.new(usuario_repo: repo)

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(id: 999, params: { correo: "x@test.com" })
          end
        end
      end
    end
  end
end
