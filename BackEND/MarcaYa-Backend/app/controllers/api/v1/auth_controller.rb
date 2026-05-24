class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request, only: [:logout]

  # POST /api/v1/auth/login
  def login
    correo = params[:correo]&.strip&.downcase
    clave  = params[:clave]

    unless correo.present? && clave.present?
      render json: { error: 'Correo y clave son requeridos' }, status: :bad_request
      return
    end

    usuario = Usuario.find_by(correo: correo)

    if usuario.nil?
      render json: { error: 'Credenciales inválidas' }, status: :unauthorized
      return
    end

    unless usuario.authenticate(clave)
      render json: { error: 'Credenciales inválidas' }, status: :unauthorized
      return
    end

    token = encode_token(usuario_id: usuario.id, rol: usuario.rol)

    render json: {
      token:  token,
      rol:    usuario.rol,
      perfil: usuario_json(usuario)
    }
  end

  # POST /api/v1/auth/registro
  def registro
    rol = params[:rol]&.strip&.downcase

    unless %w[empleado empresa].include?(rol)
      render json: { error: 'Rol inválido. Debe ser empleado o empresa' }, status: :bad_request
      return
    end

    usuario = Usuario.new(
      nombre: params[:nombre],
      correo: params[:correo]&.strip&.downcase,
      password: params[:clave],
      password_confirmation: params[:clave],
      rol: rol
    )

    unless usuario.save
      render json: { error: usuario.errors.full_messages.join(', ') }, status: :unprocessable_entity
      return
    end

    token = encode_token(usuario_id: usuario.id, rol: usuario.rol)

    render json: {
      token:  token,
      rol:    usuario.rol,
      perfil: usuario_json(usuario)
    }, status: :created
  end

  # POST /api/v1/auth/logout
  def logout
    # En una app sin blacklist de tokens, el logout es responsabilidad del cliente
    # borrando el token localmente. Aquí solo confirmamos.
    render json: { mensaje: 'Sesión cerrada correctamente' }
  end
end
