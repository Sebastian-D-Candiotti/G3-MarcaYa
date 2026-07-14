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
  # Correo de solicitud de activación enviado al ADMIN de MarcaYa.
  #
  # Se envía cuando una empresa verifica su OTP correctamente.
  # Contiene un botón "Activar cuenta" con un enlace al endpoint
  # GET /api/v1/usuarios/:id/activar-cuenta?token=XXX
  # ════════════════════════════════════════════════════════════════
  def correo_solicitud_activacion_admin(admin_email, usuario_id, nombre_empresa, ruc, correo_empresa, token)
    @nombre_empresa = nombre_empresa
    @ruc = ruc
    @correo_empresa = correo_empresa

    host_options = Rails.application.config.action_mailer.default_url_options || { host: "localhost", port: 3000 }
    host = host_options[:host]
    port = host_options[:port]
    protocol = host_options[:protocol] || (port == 443 ? "https" : "http")

    base_url = if port && port != 80 && port != 443
                   "#{protocol}://#{host}:#{port}"
                 else
                   "#{protocol}://#{host}"
                 end

    @activation_url = "#{base_url}/api/v1/usuarios/#{usuario_id}/activar-cuenta?token=#{token}"

    mail(
      to: admin_email,
      subject: "[Solicitud] Activar cuenta empresa: #{nombre_empresa} - MarcaYa"
    )
  end
end
