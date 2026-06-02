# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/usuarios/obtener_usuario"

module Application
  module UseCases
    module Usuarios
      class ObtenerUsuarioTest < Minitest::Test
        def test_ejecutar_returns_usuario
          usuario = Domain::Entities::Usuario.new(
            id: 1, correo: "test@test.com",
            clave_hash: "hash", rol: "empleado", estado: true
          )
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| usuario }

          use_case = ObtenerUsuario.new(usuario_repo: repo)
          result = use_case.ejecutar(id: 1)

          assert_equal usuario, result
        end

        def test_ejecutar_raises_usuario_no_encontrado
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::UsuarioNoEncontradoError
          end

          use_case = ObtenerUsuario.new(usuario_repo: repo)

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
