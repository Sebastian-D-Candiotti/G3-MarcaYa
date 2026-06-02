# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/auth/login_usuario"

module Application
  module UseCases
    module Auth
      class LoginUsuarioTest < Minitest::Test
        def setup
          @usuario_activo = Domain::Entities::Usuario.new(
            id: 1, correo: "empresa@test.com",
            clave_hash: "plaintext123",
            rol: "empresa", estado: true
          )
          @usuario_inactivo = Domain::Entities::Usuario.new(
            id: 2, correo: "inactiva@test.com",
            clave_hash: "secret789",
            rol: "empresa", estado: false
          )
          @called = []
        end

        def repo_que_encuentra(usuario)
          r = Object.new
          r.define_singleton_method(:find_by_correo) { |_| usuario }
          r.define_singleton_method(:guardar) { |u| u }
          r
        end

        def repo_que_no_encuentra
          r = Object.new
          r.define_singleton_method(:find_by_correo) { |_| nil }
          r
        end

        def bcrypt_que_verifica(valor)
          s = Object.new
          s.define_singleton_method(:verificar?) { |_, _| valor }
          s.define_singleton_method(:hash) { |_clave| "$2a$12$fakehashedpassword" }
          s
        end

        def jwt_que_genera
          s = Object.new
          s.define_singleton_method(:encode) { |_| "fake.jwt.token" }
          s
        end

        def test_ejecutar_returns_usuario_and_token_on_success
          use_case = LoginUsuario.new(
            usuario_repo: repo_que_encuentra(@usuario_activo),
            bcrypt_service: bcrypt_que_verifica(true),
            jwt_service: jwt_que_genera
          )

          result = use_case.ejecutar(correo: "empresa@test.com", clave: "clave123")

          assert_equal @usuario_activo, result[:usuario]
          assert_equal "fake.jwt.token", result[:token]
        end

        def test_ejecutar_raises_usuario_no_encontrado_for_unknown_correo
          use_case = LoginUsuario.new(
            usuario_repo: repo_que_no_encuentra,
            bcrypt_service: bcrypt_que_verifica(true),
            jwt_service: jwt_que_genera
          )

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(correo: "noexiste@test.com", clave: "clave")
          end
        end

        def test_ejecutar_raises_credenciales_invalidas_for_wrong_password
          use_case = LoginUsuario.new(
            usuario_repo: repo_que_encuentra(@usuario_activo),
            bcrypt_service: bcrypt_que_verifica(false),
            jwt_service: jwt_que_genera
          )

          assert_raises Domain::Errors::CredencialesInvalidasError do
            use_case.ejecutar(correo: "empresa@test.com", clave: "wrongpass")
          end
        end

        def test_ejecutar_passes_correct_payload_to_jwt_service
          usuario = @usuario_activo
          payload_captured = nil
          jwt_service = Object.new
          jwt_service.define_singleton_method(:encode) do |payload|
            payload_captured = payload
            "fake.jwt.token"
          end

          use_case = LoginUsuario.new(
            usuario_repo: repo_que_encuentra(usuario),
            bcrypt_service: bcrypt_que_verifica(true),
            jwt_service: jwt_service
          )

          use_case.ejecutar(correo: "empresa@test.com", clave: "clave123")

          assert_equal usuario.id, payload_captured["user_id"]
          assert_equal "empresa", payload_captured["rol"]
        end

        def test_ejecutar_skips_migration_when_hash_is_already_bcrypt
          usuario_con_bcrypt = Domain::Entities::Usuario.new(
            id: 3, correo: "bcrypt@test.com",
            clave_hash: "$2a$12$abcdefghijklmnopqrstuv",
            rol: "empleado", estado: true
          )

          hash_called = false
          bcrypt_service = Object.new
          bcrypt_service.define_singleton_method(:verificar?) { |_, _| true }
          bcrypt_service.define_singleton_method(:hash) { |_| hash_called = true; "hash" }

          guardar_called = false
          usuario_repo = Object.new
          usuario_repo.define_singleton_method(:find_by_correo) { |_| usuario_con_bcrypt }
          usuario_repo.define_singleton_method(:guardar) { |_| guardar_called = true; usuario_con_bcrypt }

          use_case = LoginUsuario.new(
            usuario_repo: usuario_repo,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_que_genera
          )

          use_case.ejecutar(correo: "bcrypt@test.com", clave: "clave123")

          refute hash_called, "Should not re-hash when password is already bcrypt"
          refute guardar_called, "Should not call guardar when no migration needed"
        end

        def test_ejecutar_raises_usuario_inactivo_for_inactive_user
          use_case = LoginUsuario.new(
            usuario_repo: repo_que_encuentra(@usuario_inactivo),
            bcrypt_service: bcrypt_que_verifica(true),
            jwt_service: jwt_que_genera
          )

          assert_raises Domain::Errors::UsuarioInactivoError do
            use_case.ejecutar(correo: "inactiva@test.com", clave: "secret789")
          end
        end
      end
    end
  end
end
