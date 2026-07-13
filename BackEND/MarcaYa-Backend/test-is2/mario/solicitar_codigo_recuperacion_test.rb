# frozen_string_literal: true

# ─── PU-01, PU-02, PU-03 ──────────────────────────────────────────
# Pruebas unitarias para SolicitarCodigoRecuperacion
#
# Este use case:
#   1. Busca el usuario por correo
#   2. Si existe: genera código de 6 dígitos, lo guarda, envía email
#   3. Si no existe: no hace nada (anti-enumeración)
#   4. Siempre retorna el mismo mensaje (por seguridad)
#
# Complejidad ciclomática V(G) = 2 (1 decisión: if usuario)

require_relative "../test_helper"

module TestIs2
  module SolicitarCodigoRecuperacionTests
    class SolicitarCodigoRecuperacionTest < Minitest::Test
      include TestIs2

      # ── PU-01: Correo existente genera código y envía email ───
      def test_correo_existente_genera_codigo_y_envia_email
        usuario = build_usuario(correo: "maria@test.com")
        repo = build_usuario_repo(usuario)
        notificador = build_notificador

        use_case = Application::UseCases::Auth::SolicitarCodigoRecuperacion.new(
          usuario_repo: repo,
          notificador: notificador
        )

        resultado = use_case.ejecutar(correo: "maria@test.com")

        # Verificar que retorna el mensaje estándar (anti-enumeración)
        assert_equal "Código enviado si el correo existe", resultado[:mensaje]

        # Verificar que el notificador fue invocado con los datos correctos
        assert_equal "maria@test.com", notificador.enviar_codigo_args[:destino]
        assert_match(/\A\d{6}\z/, notificador.enviar_codigo_args[:codigo])
      end

      # ── PU-02: Correo inexistente retorna mismo mensaje ────────
      # (Anti-enumeración: no revela si el correo existe o no)
      def test_correo_inexistente_retorna_mismo_mensaje
        repo = build_usuario_repo_vacio
        notificador = build_notificador

        use_case = Application::UseCases::Auth::SolicitarCodigoRecuperacion.new(
          usuario_repo: repo,
          notificador: notificador
        )

        resultado = use_case.ejecutar(correo: "noexiste@test.com")

        # El mensaje debe ser idéntico al caso exitoso
        assert_equal "Código enviado si el correo existe", resultado[:mensaje]

        # El notificador NO debe haber sido invocado
        assert_nil notificador.enviar_codigo_args
      end

      # ── PU-03: Código generado tiene exactamente 6 dígitos ─────
      def test_codigo_generado_tiene_6_digitos
        usuario = build_usuario(correo: "pedro@test.com")
        repo = build_usuario_repo(usuario)

        captura_codigo = nil
        notificador = Object.new
        notificador.define_singleton_method(:enviar_codigo) do |destino:, codigo:|
          captura_codigo = codigo
        end

        use_case = Application::UseCases::Auth::SolicitarCodigoRecuperacion.new(
          usuario_repo: repo,
          notificador: notificador
        )

        use_case.ejecutar(correo: "pedro@test.com")

        # El código debe tener exactamente 6 dígitos numéricos
        refute_nil captura_codigo
        assert_equal 6, captura_codigo.length
        assert_match(/\A\d{6}\z/, captura_codigo)
      end
    end
  end
end
