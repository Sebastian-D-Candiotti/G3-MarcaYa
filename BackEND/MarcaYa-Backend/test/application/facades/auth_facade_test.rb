# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/usuario"
require_relative "../../../app/domain/entities/empleado"
require_relative "../../../app/domain/entities/empresa"
require_relative "../../../app/domain/value_objects/rol_usuario"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/auth/login_usuario"
require_relative "../../../app/application/use_cases/auth/registrar_usuario"
require_relative "../../../app/application/use_cases/auth/cerrar_sesion"
require_relative "../../../app/application/facades/auth_facade"

module Application
  module Facades
    class AuthFacadeTest < Minitest::Test
      def setup
        @usuario = Domain::Entities::Usuario.new(
          id: 1, correo: "test@test.com",
          clave_hash: "$2a$12$hash", rol: "empleado", estado: true
        )
      end

      def test_login_delegates_to_login_usuario
        usuario_snapshot = @usuario
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:find_by_correo) { |_| usuario_snapshot }
        usuario_repo.define_singleton_method(:guardar) { |u| u }

        bcrypt_service = Object.new
        bcrypt_service.define_singleton_method(:verificar?) { |_, _| true }
        bcrypt_service.define_singleton_method(:hash) { |_| "$2a$12$hash" }

        jwt_service = Object.new
        jwt_service.define_singleton_method(:encode) { |_| "fake.jwt.token" }

        facade = AuthFacade.new(
          usuario_repo: usuario_repo,
          empleado_repo: Object.new,
          empresa_repo: Object.new,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service
        )

        result = facade.login(correo: "test@test.com", clave: "pass")

        assert_equal usuario_snapshot, result[:usuario]
        assert_equal "fake.jwt.token", result[:token]
      end

      def test_registro_delegates_to_registrar_usuario
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:exists_by_correo?) { |_| false }
        usuario_repo.define_singleton_method(:guardar) do |u|
          Domain::Entities::Usuario.new(
            id: 10, correo: u.correo,
            clave_hash: u.clave_hash, rol: u.rol.valor,
            estado: u.estado
          )
        end

        empleado_repo = Object.new
        guardado = nil
        empleado_repo.define_singleton_method(:guardar) { |e| guardado = e; e }

        bcrypt_service = Object.new
        bcrypt_service.define_singleton_method(:hash) { |_| "$2a$12$hash" }

        jwt_service = Object.new
        jwt_service.define_singleton_method(:encode) { |_| "fake.jwt.token" }

        facade = AuthFacade.new(
          usuario_repo: usuario_repo,
          empleado_repo: empleado_repo,
          empresa_repo: Object.new,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service
        )

        result = facade.registro(
          correo: "nuevo@test.com", clave: "pass123",
          rol: "empleado", nombre: "Juan"
        )

        assert_instance_of Domain::Entities::Usuario, result[:usuario]
        assert_equal "fake.jwt.token", result[:token]
        assert_instance_of Domain::Entities::Empleado, guardado
      end

      def test_logout_returns_success_message
        facade = AuthFacade.new(
          usuario_repo: Object.new,
          empleado_repo: Object.new,
          empresa_repo: Object.new,
          bcrypt_service: Object.new,
          jwt_service: Object.new
        )

        result = facade.logout(usuario_id: 1)
        assert_equal "Sesión cerrada exitosamente", result[:mensaje]
      end

      def test_login_raises_credenciales_invalidas_on_wrong_password
        usuario_snapshot = @usuario
        usuario_repo = Object.new
        usuario_repo.define_singleton_method(:find_by_correo) { |_| usuario_snapshot }
        usuario_repo.define_singleton_method(:guardar) { |u| u }

        bcrypt_service = Object.new
        bcrypt_service.define_singleton_method(:verificar?) { |_, _| false }
        bcrypt_service.define_singleton_method(:hash) { |_| "$2a$12$hash" }

        facade = AuthFacade.new(
          usuario_repo: usuario_repo,
          empleado_repo: Object.new,
          empresa_repo: Object.new,
          bcrypt_service: bcrypt_service,
          jwt_service: Object.new
        )

        assert_raises Domain::Errors::CredencialesInvalidasError do
          facade.login(correo: "test@test.com", clave: "wrong")
        end
      end
    end
  end
end
