# frozen_string_literal: true

class PasswordRecoveryMailer < ApplicationMailer
  default from: "MarcaYa <onboarding@resend.dev>"

  def codigo_recuperacion(correo, codigo)
    @codigo = codigo
    @expira_en = "15 minutos"
    mail(to: correo, subject: "Código de recuperación — MarcaYa")
  end
end
