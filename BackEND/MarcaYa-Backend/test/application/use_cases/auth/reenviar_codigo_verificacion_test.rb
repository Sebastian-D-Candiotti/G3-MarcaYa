# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/auth/reenviar_codigo_verificacion"

module Application
  module UseCases
    module Auth
      class ReenviarCodigoVerificacionTest < Minitest::Test
        def usuario(estado: false, estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_PENDIENTE)
          Domain::Entities::Usuario.new(
            id: 1,
            correo: "nuevo@test.com",
            clave_hash: "$2a$12$hash",
            rol: "empleado",
            estado: estado,
            estado_verificacion: estado_verificacion,
            codigo_verificacion_digest: "digest-old",
            codigo_verificacion_expira_en: Time.now + 60
          )
        end

        def repo(usuario)
          r = Object.new
          r.define_singleton_method(:find_by_correo) { |_| usuario }
          r.define_singleton_method(:guardar) { |u| u }
          r
        end

        def code_service
          s = Object.new
          s.define_singleton_method(:generate) { "654321" }
          s.define_singleton_method(:digest) { |codigo| "digest-#{codigo}" }
          s.define_singleton_method(:expires_at) { Time.now + 600 }
          s
        end

        def mailer(delivered:)
          delivery = Object.new
          delivery.define_singleton_method(:deliver_now) { delivered }

          message = Object.new
          message.define_singleton_method(:codigo_verificacion) { delivery }

          m = Object.new
          m.define_singleton_method(:with) { |_| message }
          m
        end

        def test_ejecutar_regenerates_code_and_keeps_user_pending
          use_case = ReenviarCodigoVerificacion.new(
            usuario_repo: repo(usuario),
            verification_code_service: code_service,
            verification_mailer: mailer(delivered: true)
          )

          actualizado = use_case.ejecutar(correo: "nuevo@test.com")

          refute actualizado.activo?
          assert actualizado.pendiente_verificacion?
          assert_equal "digest-654321", actualizado.codigo_verificacion_digest
          assert actualizado.codigo_verificacion_expira_en > Time.now
        end

        def test_ejecutar_rejects_already_verified_user
          use_case = ReenviarCodigoVerificacion.new(
            usuario_repo: repo(usuario(
              estado: true,
              estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_ACTIVO
            )),
            verification_code_service: code_service,
            verification_mailer: mailer(delivered: true)
          )

          assert_raises Domain::Errors::CodigoVerificacionUsadoError do
            use_case.ejecutar(correo: "nuevo@test.com")
          end
        end
      end
    end
  end
end
