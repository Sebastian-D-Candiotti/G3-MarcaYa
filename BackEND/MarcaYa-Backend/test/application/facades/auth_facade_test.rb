# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/usuario"
require_relative "../../../app/domain/entities/empleado"
require_relative "../../../app/domain/entities/empresa"
require_relative "../../../app/domain/value_objects/rol_usuario"
require_relative "../../../app/domain/errors"
require_relative "../../../app/application/use_cases/auth/login_usuario"
require_relative "../../../app/application/use_cases/auth/registrar_usuario"
require_relative "../../../app/application/use_cases/auth/verificar_cuenta"
require_relative "../../../app/application/use_cases/auth/reenviar_codigo_verificacion"
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

      def verification_code_service
        s = Object.new
        s.define_singleton_method(:generate) { "123456" }
        s.define_singleton_method(:digest) { |codigo| "digest-#{codigo}" }
        s.define_singleton_method(:expires_at) { Time.now + 600 }
        s.define_singleton_method(:matches?) { |codigo, digest| digest == "digest-#{codigo}" }
        s
      end

      def verification_mailer
        delivery = Object.new
        delivery.define_singleton_method(:deliver_now) { true }

        message = Object.new
        message.define_singleton_method(:codigo_verificacion) { delivery }

        mailer = Object.new
        mailer.define_singleton_method(:with) { |_| message }
        mailer
      end

      def build_facade(usuario_repo:, empleado_repo: Object.new, empresa_repo: Object.new,
                       bcrypt_service: Object.new, jwt_service: Object.new, notificador: Object.new,
                       reniec_service: Object.new)
        AuthFacade.new(
          usuario_repo: usuario_repo,
          empleado_repo: empleado_repo,
          empresa_repo: empresa_repo,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service,
          notificador: notificador,
          verification_code_service: verification_code_service,
          verification_mailer: verification_mailer,
          reniec_service: reniec_service
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

        facade = build_facade(
          usuario_repo: usuario_repo,
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
            estado: u.estado,
            estado_verificacion: u.estado_verificacion,
            codigo_verificacion_digest: u.codigo_verificacion_digest,
            codigo_verificacion_expira_en: u.codigo_verificacion_expira_en
          )
        end

        empleado_repo = Object.new
        guardado = nil
        empleado_repo.define_singleton_method(:guardar) { |e| guardado = e; e }
        empleado_repo.define_singleton_method(:exists_by_dni?) { |_| false }

        reniec_service_mock = Object.new
        reniec_service_mock.define_singleton_method(:consultar) { |_| { nombres: "Juan", apellido_paterno: "Pérez", apellido_materno: "García" } }

        bcrypt_service = Object.new
        bcrypt_service.define_singleton_method(:hash) { |_| "$2a$12$hash" }

        jwt_service = Object.new
        jwt_service.define_singleton_method(:encode) { |_| "fake.jwt.token" }

        facade = build_facade(
          usuario_repo: usuario_repo,
          empleado_repo: empleado_repo,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service,
          reniec_service: reniec_service_mock
        )

        result = facade.registro(
          correo: "nuevo@test.com", clave: "pass123",
          rol: "empleado", nombre: "Juan", dni: "87654321"
        )

        assert_instance_of Domain::Entities::Usuario, result[:usuario]
        assert result[:requiere_verificacion]
        assert result[:usuario].pendiente_verificacion?
        assert_instance_of Domain::Entities::Empleado, guardado
      end

      def test_logout_returns_success_message
        facade = build_facade(usuario_repo: Object.new)

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

        facade = build_facade(
          usuario_repo: usuario_repo,
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
