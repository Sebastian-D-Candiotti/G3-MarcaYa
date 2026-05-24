module JwtAuthenticatable
  extend ActiveSupport::Concern

  SECRET_KEY = Rails.application.secret_key_base || 'marcaya_secret_key_dev'

  # ── Generar JWT con expiración de 24h ──────────────────────
  def encode_token(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # ── Decodificar JWT ─────────────────────────────────────────
  def decode_token(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature => _e
    nil
  end

  # ── Extraer token del header Authorization ──────────────────
  def token_from_header
    header = request.headers['Authorization']
    return nil if header.blank?
    header.split.last
  end

  # ── Autenticar request (before_action) ──────────────────────
  def authenticate_request
    token = token_from_header
    if token.nil?
      render json: { error: 'Token no proporcionado' }, status: :unauthorized
      return
    end

    payload = decode_token(token)
    if payload.nil?
      render json: { error: 'Token inválido o expirado' }, status: :unauthorized
      return
    end

    @current_usuario = Usuario.find_by(id: payload['usuario_id'])
    if @current_usuario.nil?
      render json: { error: 'Usuario no encontrado' }, status: :unauthorized
    end
  end

  # ── Helper de acceso al usuario autenticado ─────────────────
  def current_usuario
    @current_usuario
  end
end
