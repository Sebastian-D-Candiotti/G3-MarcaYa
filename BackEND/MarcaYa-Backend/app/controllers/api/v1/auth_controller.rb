class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [:login, :registro, :verificar_otp]

  def login
    correo = params[:correo]
    clave  = params[:clave]

    resultado = Rails.configuration.di.auth_facade.login(correo: correo, clave: clave)

    usuario = resultado[:usuario]
    token = resultado[:token]

    perfil = build_perfil(usuario)

    render json: {
      token: token,
      rol: usuario.rol.to_s,
      perfil: perfil
    }
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :unauthorized
  rescue ::Domain::Errors::CredencialesInvalidasError
    render json: { error: "Contraseña incorrecta" }, status: :unauthorized
  rescue ::Domain::Errors::UsuarioInactivoError
    render json: { error: "Usuario no encontrado" }, status: :unauthorized
  end

  def registro
    resultado = Rails.configuration.di.auth_facade.registro(params.permit!.to_h.symbolize_keys)

    render json: {
      mensaje: "Usuario registrado",
      id: resultado[:usuario].id,
      token: resultado[:token]
    }, status: :created
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def verificar_otp
    ruc = params[:ruc].to_s.strip
    codigo = params[:codigo].to_s.strip

    if ruc.empty? || codigo.empty?
      render json: { error: "El RUC y el código de verificación son obligatorios" }, status: :unprocessable_entity
      return
    end

    empresa_repo = Rails.configuration.di.repos[:empresa]
    unless empresa_repo.verificar_codigo_ruc?(ruc, codigo)
      render json: { error: "Código de verificación inválido o expirado" }, status: :unprocessable_entity
      return
    end

    empresa = empresa_repo.find_by_ruc(ruc)
    if empresa.nil?
      render json: { error: "Empresa no registrada" }, status: :not_found
      return
    end

    empresa_actualizada = Domain::Entities::Empresa.new(
      id: empresa.id,
      usuario_id: empresa.usuario_id,
      nombre_empresa: empresa.nombre_empresa,
      ruc: empresa.ruc,
      descripcion: empresa.descripcion,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      foto_url: empresa.foto_url,
      estado: empresa.estado,
      otp_verificado: true,
      created_at: empresa.created_at,
      updated_at: empresa.updated_at
    )
    empresa_repo.guardar(empresa_actualizada)

    render json: { mensaje: "Código OTP verificado correctamente" }
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
      empresa_id: empresa&.id,
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
      otp_verificado: empresa&.otp_verificado
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
      foto_url: empleado&.foto_url
    }
  end
end
