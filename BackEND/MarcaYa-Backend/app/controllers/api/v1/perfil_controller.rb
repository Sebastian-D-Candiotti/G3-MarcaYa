class Api::V1::PerfilController < Api::V1::BaseController
  # GET /api/v1/perfil
  def show
    usuario = Rails.configuration.di.usuario_facade.obtener(id: current_user.id)
    perfil = build_perfil(usuario)
    render json: perfil
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  end

  # PUT /api/v1/perfil
  def update
    usuario_facade = Rails.configuration.di.usuario_facade

    # Update user correo if provided
    if params[:correo].present?
      usuario_facade.actualizar(
        id: current_user.id,
        params: { correo: params[:correo] }
      )
    end

    # Update role-specific fields using the ORM record's rol string
    if current_user.rol == "empleado"
      update_empleado_fields
    elsif current_user.rol == "empresa"
      update_empresa_fields
    end

    # Reload and return updated profile (domain entity)
    usuario_actualizado = usuario_facade.obtener(id: current_user.id)
    perfil = build_perfil(usuario_actualizado)
    render json: perfil
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  rescue ActiveRecord::RecordInvalid, ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def build_perfil(usuario)
    if usuario.es_empresa?
      build_empresa_perfil(usuario)
    else
      build_empleado_perfil(usuario)
    end
  end

  def build_empresa_perfil(usuario)
    empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(usuario.id)

    {
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
      nombre: empresa&.nombre_empresa,
      nombre_empresa: empresa&.nombre_empresa,
      descripcion: empresa&.descripcion,
      telefono: empresa&.telefono,
      direccion: empresa&.direccion,
      ruc: empresa&.ruc,
      foto_url: empresa&.foto_url,
      estado: empresa&.estado,
      otp_verificado: empresa&.otp_verificado,
      created_at: usuario.created_at
    }
  end

  def build_empleado_perfil(usuario)
    empleado = Rails.configuration.di.repos[:empleado].find_by_usuario_id(usuario.id)

    {
      id: usuario.id,
      employee_id: empleado&.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
      nombre: empleado&.nombre,
      apellido: empleado&.apellido,
      descripcion: empleado&.descripcion,
      telefono: empleado&.telefono,
      foto_url: empleado&.foto_url,
      dni: empleado&.dni,
      device_id: empleado&.device_id,
      created_at: usuario.created_at
    }
  end

  def update_empleado_fields
    empleado = Rails.configuration.di.repos[:empleado].find_by_usuario_id(current_user.id)
    return unless empleado

    attrs = {
      nombre: params[:nombre],
      apellido: params[:apellido],
      telefono: params[:telefono],
      descripcion: params[:descripcion]
    }.compact

    return if attrs.empty?

    actualizado = Domain::Entities::Empleado.new(
      id: empleado.id,
      usuario_id: empleado.usuario_id,
      nombre: attrs[:nombre] || empleado.nombre,
      apellido: attrs[:apellido] || empleado.apellido,
      dni: empleado.dni,
      estado: empleado.estado,
      telefono: attrs[:telefono] || empleado.telefono,
      descripcion: attrs[:descripcion] || empleado.descripcion,
      foto_url: empleado.foto_url,
      created_at: empleado.created_at,
      updated_at: empleado.updated_at
    )

    Rails.configuration.di.repos[:empleado].guardar(actualizado)
  end

  def update_empresa_fields
    empresa = Rails.configuration.di.repos[:empresa].find_by_usuario_id(current_user.id)
    return unless empresa

    attrs = {
      nombre_empresa: params[:nombre_empresa],
      descripcion: params[:descripcion],
      telefono: params[:telefono],
      direccion: params[:direccion],
      ruc: params[:ruc]
    }.compact

    return if attrs.empty?

    actualizada = Domain::Entities::Empresa.new(
      id: empresa.id,
      usuario_id: empresa.usuario_id,
      nombre_empresa: attrs[:nombre_empresa] || empresa.nombre_empresa,
      ruc: attrs[:ruc] || empresa.ruc,
      descripcion: attrs[:descripcion] || empresa.descripcion,
      direccion: attrs[:direccion] || empresa.direccion,
      telefono: attrs[:telefono] || empresa.telefono,
      foto_url: empresa.foto_url,
      estado: empresa.estado,
      created_at: empresa.created_at,
      updated_at: empresa.updated_at
    )

    Rails.configuration.di.repos[:empresa].guardar(actualizada)
  end
end
