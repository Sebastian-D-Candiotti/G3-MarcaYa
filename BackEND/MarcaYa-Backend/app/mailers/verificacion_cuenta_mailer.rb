class VerificacionCuentaMailer < ApplicationMailer
  # El from se hereda de ApplicationMailer (usa MAIL_FROM o SMTP_USERNAME)
  # Configurar MAIL_FROM en las variables de entorno de Render

  def codigo_verificacion
    @correo = params[:correo]
    @codigo = params[:codigo]
    @minutos_validez = params[:minutos_validez] || 10

    mail(
      to: @correo,
      subject: "Codigo de verificacion MarcaYA"
    )
  end
end
