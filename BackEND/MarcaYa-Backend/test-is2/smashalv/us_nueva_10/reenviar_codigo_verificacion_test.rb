# frozen_string_literal: true

require_relative "../test_helper"


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

        def test_ejecutar_invalidates_previous_digest_and_sends_once
          saved = nil
          sent = []
          usuario_repo = repo(usuario)
          usuario_repo.define_singleton_method(:guardar) { |u| saved = u; u }

          delivery = Object.new
          delivery.define_singleton_method(:deliver_now) { sent << :delivered; true }
          message = Object.new
          message.define_singleton_method(:codigo_verificacion) { delivery }
          mailer = Object.new
          mailer.define_singleton_method(:with) do |params|
            sent << params
            message
          end

          ReenviarCodigoVerificacion.new(
            usuario_repo: usuario_repo,
            verification_code_service: code_service,
            verification_mailer: mailer
          ).ejecutar(correo: "nuevo@test.com")

          refute_equal "digest-old", saved.codigo_verificacion_digest
          assert_equal "digest-654321", saved.codigo_verificacion_digest
          assert_equal({ correo: "nuevo@test.com", codigo: "654321", minutos_validez: 10 }, sent.first)
          assert_equal [:delivered], sent.drop(1)
        end

        def test_ejecutar_wraps_mail_delivery_failure
          failing_delivery = Object.new
          failing_delivery.define_singleton_method(:deliver_now) { raise "smtp unavailable" }
          message = Object.new
          message.define_singleton_method(:codigo_verificacion) { failing_delivery }
          failing_mailer = Object.new
          failing_mailer.define_singleton_method(:with) { |_| message }

          use_case = ReenviarCodigoVerificacion.new(
            usuario_repo: repo(usuario),
            verification_code_service: code_service,
            verification_mailer: failing_mailer
          )

          error = assert_raises Domain::Errors::CorreoVerificacionNoEnviadoError do
            use_case.ejecutar(correo: "nuevo@test.com")
          end
          assert_match(/smtp unavailable/, error.message)
        end
      end
    end
  end
end
