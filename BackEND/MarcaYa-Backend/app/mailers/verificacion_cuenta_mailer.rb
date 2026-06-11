class VerificacionCuentaMailer < ApplicationMailer
  default from: -> { ENV.fetch("MAIL_FROM", "no-reply@marcaya.local") }

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
