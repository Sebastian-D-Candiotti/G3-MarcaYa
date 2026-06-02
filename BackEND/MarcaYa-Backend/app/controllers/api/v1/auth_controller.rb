class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [:login, :registro]

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
      foto_url: empresa&.foto_url
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
