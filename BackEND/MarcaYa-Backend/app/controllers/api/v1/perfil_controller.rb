class Api::V1::PerfilController < ApplicationController
  before_action :authenticate_request

  # GET /api/v1/perfil — devuelve el perfil del usuario autenticado
  def show
    render json: { perfil: usuario_json(current_usuario) }
  end

  # PUT /api/v1/perfil — actualiza nombre y/o correo del usuario autenticado
  def update
    usuario = current_usuario

    nuevo_nombre = params[:nombre]
    nuevo_correo = params[:correo]&.strip&.downcase

    usuario.nombre = nuevo_nombre if nuevo_nombre.present?
    usuario.correo = nuevo_correo if nuevo_correo.present?

    unless usuario.save
      render json: { error: usuario.errors.full_messages.join(', ') }, status: :unprocessable_entity
      return
    end

    render json: { perfil: usuario_json(usuario), mensaje: 'Perfil actualizado correctamente' }
  end

  # GET /api/v1/perfil/:id — devuelve un usuario por ID
  # Solo admin puede ver cualquier usuario; otros solo se ven a sí mismos
  def show_by_id
    usuario = Usuario.find_by(id: params[:id])

    if usuario.nil?
      render json: { error: 'Usuario no encontrado' }, status: :not_found
      return
    end

    unless current_usuario.rol == 'admin' || current_usuario.id == usuario.id
      render json: { error: 'No autorizado para ver este perfil' }, status: :forbidden
      return
    end

    render json: { perfil: usuario_json(usuario) }
  end
end
