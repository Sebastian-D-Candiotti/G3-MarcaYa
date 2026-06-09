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
end
