class Api::V1::AuthController < ApplicationController
  def login
    correo = params[:correo]
    clave  = params[:clave]

    usuario = Usuario.find_by(correo: correo)

    if usuario.nil?
      render json: {
        error: "Usuario no encontrado"
      }, status: :unauthorized
      return
    end

    if usuario.clave_hash != clave
      render json: {
        error: "Contraseña incorrecta"
      }, status: :unauthorized
      return
    end

    render json: {
      token: "token_demo",
      rol: usuario.rol,
      perfil: {
        nombre: usuario.nombre
      }
    }
  end

  def registro
    render json: {
      mensaje: "Usuario registrado"
    }
  end
end
