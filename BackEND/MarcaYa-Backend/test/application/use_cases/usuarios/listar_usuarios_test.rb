# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/usuarios/listar_usuarios"

module Application
  module UseCases
    module Usuarios
      class ListarUsuariosTest < Minitest::Test
        def test_ejecutar_returns_all_usuarios
          usuarios = [
            Domain::Entities::Usuario.new(
              id: 1, correo: "a@test.com",
              clave_hash: "hash1", rol: "empleado", estado: true
            ),
            Domain::Entities::Usuario.new(
              id: 2, correo: "b@test.com",
              clave_hash: "hash2", rol: "empresa", estado: true
            )
          ]

          repo = Object.new
          repo.define_singleton_method(:todos) { usuarios }

          use_case = ListarUsuarios.new(usuario_repo: repo)
          result = use_case.ejecutar

          assert_equal 2, result.length
          assert_equal usuarios, result
        end

        def test_ejecutar_returns_empty_array_when_no_users
          repo = Object.new
          repo.define_singleton_method(:todos) { [] }

          use_case = ListarUsuarios.new(usuario_repo: repo)
          result = use_case.ejecutar

          assert_equal [], result
          assert result.empty?
        end
      end
    end
  end
end
