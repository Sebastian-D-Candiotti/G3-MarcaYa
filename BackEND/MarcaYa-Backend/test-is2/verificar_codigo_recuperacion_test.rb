# frozen_string_literal: true

# ─── PU-04, PU-05, PU-06, PU-07, PU-08 ────────────────────────────
# Pruebas unitarias para VerificarCodigoRecuperacion
#
# Este use case valida:
#   C1: ¿El usuario existe?
#   C2: ¿El código de recuperación no es nil?
#   C3: ¿El código ingresado coincide con el almacenado?
#   C4: ¿La fecha de expiración no es nil?
#   C5: ¿No ha expirado? (Time.current <= codigo_expira)
#
# Complejidad ciclomática V(G) = 6
#   5 decisiones (raise if/unless) + 1

require_relative "test_helper"

module TestIs2
  module VerificarCodigoRecuperacionTests
    class VerificarCodigoRecuperacionTest < Minitest::Test
      include TestIs2

      # ── PU-04: Código válido retorna verification_token ────────
      # Camino feliz: usuario existe, código correcto, no expirado
      def test_codigo_valido_retorna_verification_token
        usuario = build_usuario(
          correo: "ana@test.com",
          codigo_recuperacion: "123456",
          codigo_expira: 10.minutes.from_now
        )
        repo = build_usuario_repo(usuario)

        use_case = Application::UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: repo,
          jwt_service: build_jwt_service
        )

        resultado = use_case.ejecutar(correo: "ana@test.com", codigo: "123456")

        # Debe retornar un hash con verification_token
        assert_respond_to resultado, :[]
        refute_nil resultado[:verification_token]
        assert_kind_of String, resultado[:verification_token]
      end

      # ── PU-05: Usuario no existe → CodigoInvalidoError ─────────
      # C1 falsa: find_by_correo retorna nil
      def test_usuario_no_existe_lanza_codigo_invalido_error
        repo = build_usuario_repo_vacio

        use_case = Application::UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: repo,
          jwt_service: build_jwt_service
        )

        error = assert_raises Domain::Errors::CodigoInvalidoError do
          use_case.ejecutar(correo: "fantasma@test.com", codigo: "000000")
        end

        assert_kind_of Domain::Errors::CodigoInvalidoError, error
      end

      # ── PU-06: Código incorrecto → CodigoInvalidoError ─────────
      # C2 verdadera, C3 falsa: código no coincide
      def test_codigo_incorrecto_lanza_codigo_invalido_error
        usuario = build_usuario(
          correo: "luis@test.com",
          codigo_recuperacion: "123456",
          codigo_expira: 10.minutes.from_now
        )
        repo = build_usuario_repo(usuario)

        use_case = Application::UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: repo,
          jwt_service: build_jwt_service
        )

        error = assert_raises Domain::Errors::CodigoInvalidoError do
          use_case.ejecutar(correo: "luis@test.com", codigo: "999999")
        end

        assert_kind_of Domain::Errors::CodigoInvalidoError, error
      end

      # ── PU-07: Código expirado → CodigoExpiradoError ───────────
      # C4+C5: expiración existe pero ya pasó
      def test_codigo_expirado_lanza_codigo_expirado_error
        usuario = build_usuario(
          correo: "carlos@test.com",
          codigo_recuperacion: "123456",
          codigo_expira: 5.minutes.ago  # ← ya expiró
        )
        repo = build_usuario_repo(usuario)

        use_case = Application::UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: repo,
          jwt_service: build_jwt_service
        )

        error = assert_raises Domain::Errors::CodigoExpiradoError do
          use_case.ejecutar(correo: "carlos@test.com", codigo: "123456")
        end

        assert_kind_of Domain::Errors::CodigoExpiradoError, error
      end

      # ── PU-08: Código se consume (no reutilizable) ─────────────
      # Después de verificar, el código se setea a nil en el usuario
      def test_codigo_se_consuma_despues_de_verificar
        usuario = build_usuario(
          correo: "sofia@test.com",
          codigo_recuperacion: "123456",
          codigo_expira: 10.minutes.from_now
        )

        usuario_guardado = nil
        repo = Object.new
        repo.define_singleton_method(:find_by_correo) { |_| usuario }
        repo.define_singleton_method(:guardar) { |u| usuario_guardado = u }

        use_case = Application::UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: repo,
          jwt_service: build_jwt_service
        )

        use_case.ejecutar(correo: "sofia@test.com", codigo: "123456")

        # Después de usar el código, debe quedar nil (consumido)
        assert_nil usuario_guardado.codigo_recuperacion
        assert_nil usuario_guardado.codigo_expira
      end
    end
  end
end
