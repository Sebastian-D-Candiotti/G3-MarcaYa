class Api::V1::UsuariosController < Api::V1::BaseController

  # GET /api/v1/usuarios
  def index
    usuarios = Rails.configuration.di.usuario_facade.listar

    resultado = usuarios.map do |u|
      if u.es_empresa?
        empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(u.id)
        {
          id: u.id,
          rol: u.rol.to_s,
          correo: u.correo,
          nombre: empresa&.nombre_empresa,
          descripcion: empresa&.descripcion
        }
      else
        empleado = Rails.configuration.di.repos[:empleado].find_by_usuario_id(u.id)
        {
          id: u.id,
          rol: u.rol.to_s,
          correo: u.correo,
          nombre: "#{empleado&.nombre} #{empleado&.apellido}".strip,
          descripcion: empleado&.descripcion
        }
      end
    end

    render json: resultado
  end

  # GET /api/v1/usuarios/:id
  def show
    usuario = Rails.configuration.di.usuario_facade.obtener(id: params[:id])

    if usuario.es_empresa?
      render_empresa_show(usuario)
    else
      render_empleado_show(usuario)
    end
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  end

  # PUT /api/v1/usuarios/:id
  def update
    usuario = Rails.configuration.di.usuario_facade.actualizar(
      id: params[:id],
      params: { correo: params[:correo] }.compact
    )

    render json: {
      mensaje: "Usuario actualizado correctamente",
      usuario: {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol.to_s
      }
    }
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  rescue ActiveRecord::RecordInvalid, ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH /api/v1/usuarios/:id/desactivar
  def desactivar
    Rails.configuration.di.usuario_facade.desactivar(id: params[:id])

    render json: { mensaje: "Cuenta desactivada correctamente" }
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  end

  # PUT /api/v1/usuarios/:id/aprobar
  def aprobar
    usuario = Rails.configuration.di.repos[:usuario].find_by_id!(params[:id])
    if usuario.es_empresa?
      empresa_repo = Rails.configuration.di.repos[:empresa]
      empresa = empresa_repo.find_by_usuario_id(usuario.id)
      if empresa
        empresa_actualizada = Domain::Entities::Empresa.new(
          id: empresa.id,
          usuario_id: empresa.usuario_id,
          nombre_empresa: empresa.nombre_empresa,
          ruc: empresa.ruc,
          descripcion: empresa.descripcion,
          direccion: empresa.direccion,
          telefono: empresa.telefono,
          foto_url: empresa.foto_url,
          estado: "activo",
          otp_verificado: empresa.otp_verificado,
          created_at: empresa.created_at,
          updated_at: empresa.updated_at
        )
        empresa_repo.guardar(empresa_actualizada)
      end
    end

    render json: { mensaje: "Cuenta aprobada correctamente" }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def render_empresa_show(usuario)
    empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(usuario.id)
    valoraciones = Rails.configuration.di.repos[:valoracion].listar_por_empresa(empresa.id) if empresa

    promedio_estrellas = if valoraciones&.any?
                           (valoraciones.sum(&:puntuacion).to_f / valoraciones.size).round(1)
                         else
                           5
                         end

    comentarios = (valoraciones || []).map do |v|
      empleado_usuario = Rails.configuration.di.repos[:usuario].find_by_id!(v.empleado_id) rescue nil
      {
        empleado: empleado_usuario&.correo || "Anónimo",
        comentario: v.comentario
      }
    end

    obras = if empresa
              Rails.configuration.di.repos[:obra].listar_por_empresa(empresa.id).map do |o|
                { id: o.id, nombre: o.nombre, codigo_obra: o.codigo_obra }
              end
            else
              []
            end

    render json: {
      id: usuario.id,
      empresa_id: empresa&.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
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
      obras: obras
    }
  end

  def render_empleado_show(usuario)
    empleado = Rails.configuration.di.repos[:empleado].find_by_usuario_id(usuario.id)

    render json: {
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
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
