# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/usuarios/desactivar_usuario"

module Application
  module UseCases
    module Usuarios
      class DesactivarUsuarioTest < Minitest::Test
        def test_ejecutar_desactiva_and_returns_usuario
          usuario_original = Domain::Entities::Usuario.new(
            id: 1, correo: "test@test.com",
            clave_hash: "hash", rol: "empleado", estado: true
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| usuario_original }

          usuario_guardado = nil
          repo.define_singleton_method(:guardar) do |u|
            usuario_guardado = u
            u
          end

          use_case = DesactivarUsuario.new(usuario_repo: repo)
          result = use_case.ejecutar(id: 1)

          refute result.estado, "Usuario should be inactive"
          refute usuario_guardado.estado, "Saved usuario should be inactive"
        end

        def test_ejecutar_raises_usuario_no_encontrado
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::UsuarioNoEncontradoError
          end

          use_case = DesactivarUsuario.new(usuario_repo: repo)

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
