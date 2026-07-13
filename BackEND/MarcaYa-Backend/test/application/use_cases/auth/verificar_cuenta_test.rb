# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/auth/verificar_cuenta"

module Application
  module UseCases
    module Auth
      class VerificarCuentaTest < Minitest::Test
        def usuario_pendiente(expira_en: Time.now + 600)
          Domain::Entities::Usuario.new(
            id: 1,
            correo: "nuevo@test.com",
            clave_hash: "$2a$12$hash",
            rol: "empleado",
            estado: false,
            estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_PENDIENTE,
            codigo_verificacion_digest: "digest-123456",
            codigo_verificacion_expira_en: expira_en
          )
        end

        def repo(usuario)
          r = Object.new
          r.define_singleton_method(:find_by_correo) { |_| usuario }
          r.define_singleton_method(:guardar) { |u| u }
          r
        end

        def code_service(matches: true)
          s = Object.new
          s.define_singleton_method(:matches?) { |_, _| matches }
          s
        end

        def test_ejecutar_activates_user_with_valid_code
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario_pendiente),
            verification_code_service: code_service(matches: true)
          )

          usuario = use_case.ejecutar(correo: "nuevo@test.com", codigo: "123456")

          assert usuario.activo?
          assert usuario.verificado?
          assert_nil usuario.codigo_verificacion_digest
          assert_nil usuario.codigo_verificacion_expira_en
        end

        def test_ejecutar_rejects_wrong_code
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario_pendiente),
            verification_code_service: code_service(matches: false)
          )

          assert_raises Domain::Errors::CodigoVerificacionInvalidoError do
            use_case.ejecutar(correo: "nuevo@test.com", codigo: "999999")
          end
        end

        def test_ejecutar_rejects_expired_code
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario_pendiente(expira_en: Time.now - 60)),
            verification_code_service: code_service(matches: true)
          )

          assert_raises Domain::Errors::CodigoVerificacionVencidoError do
            use_case.ejecutar(correo: "nuevo@test.com", codigo: "123456")
          end
        end

        def test_ejecutar_rejects_already_verified_user
          usuario = Domain::Entities::Usuario.new(
            id: 2,
            correo: "activo@test.com",
            clave_hash: "$2a$12$hash",
            rol: "empresa",
            estado: true,
            estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_ACTIVO
          )
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario),
            verification_code_service: code_service(matches: true)
          )

          assert_raises Domain::Errors::CodigoVerificacionUsadoError do
            use_case.ejecutar(correo: "activo@test.com", codigo: "123456")
          end
        end

        def test_ejecutar_rejects_unknown_user
          use_case = VerificarCuenta.new(
            usuario_repo: repo(nil),
            verification_code_service: code_service(matches: true)
          )

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(correo: "missing@test.com", codigo: "123456")
          end
        end

        def test_ejecutar_rejects_code_with_invalid_length_or_characters
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario_pendiente),
            verification_code_service: code_service(matches: true)
          )

          ["12345", "1234567", "12A456"].each do |codigo|
            assert_raises Domain::Errors::ValidacionError do
              use_case.ejecutar(correo: "nuevo@test.com", codigo: codigo)
            end
          end
        end

        def test_ejecutar_rejects_code_at_exact_expiration_time
          now = Time.now
          use_case = VerificarCuenta.new(
            usuario_repo: repo(usuario_pendiente(expira_en: now)),
            verification_code_service: code_service(matches: true),
            clock: -> { now }
          )

          assert_raises Domain::Errors::CodigoVerificacionVencidoError do
            use_case.ejecutar(correo: "nuevo@test.com", codigo: "123456")
          end
        end
      end
    end
  end
end
