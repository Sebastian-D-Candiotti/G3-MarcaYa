# frozen_string_literal: true

# ─── PU-09, PU-10, PU-11, PU-12 ───────────────────────────────────
# Pruebas unitarias para RestablecerContrasena
#
# Este use case:
#   1. Decodifica el verification_token JWT
#   2. Verifica que purpose == "password_reset"
#   3. Busca el usuario por ID
#   4. Valida que la nueva contraseña tenga ≥ 8 caracteres
#   5. Hashea con bcrypt y guarda
#
# Condiciones evaluadas:
#   C1: JWT válido y purpose correcto
#   C2: JWT inválido o purpose incorrecto
#   C3: Contraseña ≥ 8 caracteres
#   C4: Contraseña < 8 caracteres
#
# Complejidad ciclomática V(G) = 5
#   4 decisiones (raise unless/if) + 1

require_relative "../test_helper"

module TestIs2
  module RestablecerContrasenaTests
    class RestablecerContrasenaTest < Minitest::Test
      include TestIs2

      # ── PU-09: Contraseña válida actualiza el hash ─────────────
      # Camino feliz: JWT válido, purpose correcto, contraseña ≥ 8
      def test_contrasena_valida_actualiza_el_hash
        usuario = build_usuario(
          id: 42,
          correo: "roberto@test.com",
          clave_hash: "$2a$12$oldhash"
        )

        usuario_guardado = nil
        repo = Object.new
        repo.define_singleton_method(:find_by_id!) { |_| usuario }
        repo.define_singleton_method(:guardar) { |u| usuario_guardado = u }

        bcrypt = build_bcrypt_service

        # Generar un token JWT válido con purpose correcto
        token = Jwt.encode({ "user_id" => 42, "purpose" => "password_reset" }, 5.minutes.from_now)

        use_case = Application::UseCases::Auth::RestablecerContrasena.new(
          usuario_repo: repo,
          bcrypt_service: bcrypt
        )

        resultado = use_case.ejecutar(verification_token: token, nueva_clave: "nuevaClave123")

        # Verificar mensaje de éxito
        assert_equal "Contraseña actualizada correctamente", resultado[:mensaje]

        # Verificar que el hash fue actualizado
        assert_equal "bcrypt_hash_of_nuevaClave123", usuario_guardado.clave_hash
      end

      # ── PU-10: JWT inválido → TokenRecuperacionInvalidoError ───
      # decode_verification_token lanza JWT::DecodeError → mapeado
      def test_jwt_invalido_lanza_token_recuperacion_invalido_error
        repo = build_usuario_repo_vacio
        bcrypt = build_bcrypt_service

        use_case = Application::UseCases::Auth::RestablecerContrasena.new(
          usuario_repo: repo,
          bcrypt_service: bcrypt
        )

        error = assert_raises Domain::Errors::TokenRecuperacionInvalidoError do
          use_case.ejecutar(verification_token: "token-falso-totalmente-invalido", nueva_clave: "clave1234")
        end

        assert_kind_of Domain::Errors::TokenRecuperacionInvalidoError, error
      end

      # ── PU-11: JWT con purpose incorrecto → TokenRecuperacionInvalidoError ──
      # Token válido pero purpose ≠ "password_reset"
      def test_jwt_con_purpose_incorrecto_lanza_error
        repo = build_usuario_repo_vacio
        bcrypt = build_bcrypt_service

        # Token válido pero con purpose equivocado
        token = Jwt.encode({ "user_id" => 1, "purpose" => "something_else" }, 5.minutes.from_now)

        use_case = Application::UseCases::Auth::RestablecerContrasena.new(
          usuario_repo: repo,
          bcrypt_service: bcrypt
        )

        error = assert_raises Domain::Errors::TokenRecuperacionInvalidoError do
          use_case.ejecutar(verification_token: token, nueva_clave: "clave1234")
        end

        assert_kind_of Domain::Errors::TokenRecuperacionInvalidoError, error
      end

      # ── PU-12: Contraseña < 8 caracteres → ValidacionError ─────
      # Contraseña demasiado corta
      def test_contrasena_corta_lanza_validacion_error
        usuario = build_usuario(id: 99, correo: "corto@test.com")
        repo = build_usuario_repo(usuario)
        bcrypt = build_bcrypt_service

        token = Jwt.encode({ "user_id" => 99, "purpose" => "password_reset" }, 5.minutes.from_now)

        use_case = Application::UseCases::Auth::RestablecerContrasena.new(
          usuario_repo: repo,
          bcrypt_service: bcrypt
        )

        error = assert_raises Domain::Errors::ValidacionError do
          use_case.ejecutar(verification_token: token, nueva_clave: "1234567")
        end

        assert_match(/8 caracteres/, error.message)
      end
    end
  end
end
