class ApplicationController < ActionController::API
  include JwtAuthenticatable

  private

  def usuario_json(usuario)
    {
      id:            usuario.id,
      nombre:        usuario.nombre,
      correo:        usuario.correo,
      rol:           usuario.rol,
      estado:        usuario.estado,
      fechaRegistro: usuario.created_at,
      createdAt:     usuario.created_at,
      updatedAt:     usuario.updated_at
    }
  end
end
