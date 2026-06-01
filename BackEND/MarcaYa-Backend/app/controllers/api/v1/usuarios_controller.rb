class Api::V1::UsuariosController < ApplicationController

  # GET /api/v1/usuarios
  def index
    usuarios = Usuario.all

    resultado = usuarios.map do |u|
      if u.rol == 'empresa'
        empresa = Empresa.find_by(usuario_id: u.id)
        {
          id: u.id,
          rol: u.rol,
          correo: u.correo,
          nombre: empresa&.nombre_empresa,
          descripcion: empresa&.descripcion
        }
      else
        empleado = Empleado.find_by(usuario_id: u.id)
        {
          id: u.id,
          rol: u.rol,
          correo: u.correo,
          nombre: "#{empleado&.nombre} #{empleado&.apellido}",
          descripcion: empleado&.descripcion
        }
      end
    end

    render json: resultado
  end

  # GET /api/v1/usuarios/:id
  def show
    usuario = Usuario.find(params[:id])

    if usuario.rol == 'empresa'
      empresa = Empresa.find_by(usuario_id: usuario.id)
      obras = Obra.where(empresa_id: empresa.id)
      valoraciones = Valoracion.where(empresa_id: empresa.id)
      promedio_estrellas = valoraciones.average(:puntuacion)&.round(1) || 5
      comentarios = valoraciones.map do |v|
        empleado = Usuario.find_by(id: v.empleado_id)
        {
          empleado: empleado&.correo || 'Anónimo',
          comentario: v.comentario
        }
      end

      render json: {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol,
        estado: usuario.estado,
        created_at: usuario.created_at,
        nombre_empresa: empresa&.nombre_empresa,
        descripcion: empresa&.descripcion,
        telefono: empresa&.telefono,
        direccion: empresa&.direccion,
        ruc: empresa&.ruc,
        foto_url: empresa&.foto_url,
        promedio_estrellas: promedio_estrellas,
        comentarios: comentarios,
        obras: obras.map { |o| { id: o.id, nombre: o.nombre, codigo_obra: o.codigo_obra } }
      }

    else
      empleado = Empleado.find_by(usuario_id: usuario.id)

      render json: {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol,
        estado: usuario.estado,
        created_at: usuario.created_at,
        nombre: empleado&.nombre,
        apellido: empleado&.apellido,
        telefono: empleado&.telefono,
        descripcion: empleado&.descripcion,
        foto_url: empleado&.foto_url
      }
    end
  end

  # PUT /api/v1/usuarios/:id
  def update
    usuario = Usuario.find(params[:id])
    usuario.update!(correo: params[:correo])
    render json: {
      mensaje: "Usuario actualizado correctamente",
      usuario: {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol
      }
    }
  end

  # PATCH /api/v1/usuarios/:id/desactivar
  def desactivar
    usuario = Usuario.find(params[:id])
    usuario.update!(estado: false)
    render json: { mensaje: "Cuenta desactivada correctamente" }
  end

end