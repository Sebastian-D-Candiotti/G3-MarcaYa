# frozen_string_literal: true

class UsuarioMailer < ApplicationMailer
  def correo_asociacion(correo, rol, nombre)
    @rol = rol
    @nombre = nombre
    @correo = correo
    mail(to: correo, subject: "Confirmacion de Registro y Asociacion - MarcaYa")
  end

  def correo_verificacion_ruc(correo, codigo, razon_social)
    @codigo = codigo
    @razon_social = razon_social
    @correo = correo
    mail(to: correo, subject: "Codigo de Verificacion de Empresa - MarcaYa")
  end

  # ════════════════════════════════════════════════════════════════
  # US-NUEVA-13: Correo de activación de cuenta de empresa.
  #
  # Se envía automáticamente tras verificar el OTP.
  # Contiene un botón "Activar mi cuenta" con un enlace al endpoint
  # GET /api/v1/usuarios/:id/activar-cuenta?token=XXX
  #
  # El token es HMAC-SHA256 firmado con secret_key_base y tiene
  # una validez de ~24-48 horas.
  # ════════════════════════════════════════════════════════════════
  def correo_activacion_empresa(usuario_id, correo, nombre_empresa, ruc)
    @nombre_empresa = nombre_empresa
    @ruc = ruc
    @correo = correo

    # Generar token de activación firmado
    @token = Api::V1::UsuariosController.generar_token_activacion(usuario_id)

    # Construir URL de activación
    host_options = Rails.application.config.action_mailer.default_url_options || { host: "localhost", port: 3000 }
    host = host_options[:host]
    port = host_options[:port]
    protocol = host_options[:protocol] || (port == 443 ? "https" : "http")

    base_url = if port && port != 80 && port != 443
                 "#{protocol}://#{host}:#{port}"
               else
                 "#{protocol}://#{host}"
               end

    @activation_url = "#{base_url}/api/v1/usuarios/#{usuario_id}/activar-cuenta?token=#{@token}"

    # Log para debugging
    Rails.logger.info(
      "\n========================================\n" \
      "[ACTIVACIÓN] Correo de activación enviado a: #{correo}\n" \
      "Empresa: #{nombre_empresa} | RUC: #{ruc}\n" \
      "URL de activación: #{@activation_url}\n" \
      "========================================\n"
    )

    mail(
      to: correo,
      subject: "Activa tu cuenta de empresa - MarcaYa"
    )
  end
end
