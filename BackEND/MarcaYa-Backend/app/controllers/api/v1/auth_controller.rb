class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [
    :login,
    :registro,
    :verificar_cuenta,
    :reenviar_codigo_verificacion
  ]

  def login
    resultado = Rails.configuration.di.auth_facade.login(
      correo: params[:correo],
      clave: params[:clave]
    )

    usuario = resultado[:usuario]

    render json: {
      token: resultado[:token],
      rol: usuario.rol.to_s,
      perfil: build_perfil(usuario)
    }
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :unauthorized
  rescue ::Domain::Errors::CredencialesInvalidasError
    render json: { error: "Contrasena incorrecta" }, status: :unauthorized
  rescue ::Domain::Errors::CuentaPendienteVerificacionError
    render json: { error: "Cuenta pendiente de verificacion" }, status: :forbidden
  rescue ::Domain::Errors::UsuarioInactivoError
    render json: { error: "Usuario no encontrado" }, status: :unauthorized
  end

  def registro
    resultado = Rails.configuration.di.auth_facade.registro(params.permit!.to_h.symbolize_keys)
    usuario = resultado[:usuario]

    render json: {
      mensaje: "Usuario registrado. Revisa tu correo para verificar la cuenta.",
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
      estado_verificacion: usuario.estado_verificacion,
      requiere_verificacion: resultado[:requiere_verificacion]
    }, status: :created
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ::Domain::Errors::CorreoVerificacionNoEnviadoError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def verificar_cuenta
    usuario = Rails.configuration.di.auth_facade.verificar_cuenta(
      correo: params[:correo],
      codigo: params[:codigo]
    )

    render json: {
      mensaje: "Cuenta verificada",
      usuario: {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol.to_s,
        estado_verificacion: usuario.estado_verificacion
      }
    }, status: :ok
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  rescue ::Domain::Errors::CodigoVerificacionInvalidoError
    render json: { error: "Codigo incorrecto" }, status: :unprocessable_entity
  rescue ::Domain::Errors::CodigoVerificacionVencidoError
    render json: { error: "Codigo vencido" }, status: :unprocessable_entity
  rescue ::Domain::Errors::CodigoVerificacionUsadoError
    render json: { error: "Codigo ya utilizado" }, status: :unprocessable_entity
  end

  def reenviar_codigo_verificacion
    usuario = Rails.configuration.di.auth_facade.reenviar_codigo_verificacion(
      correo: params[:correo]
    )

    render json: {
      mensaje: "Codigo reenviado",
      correo: usuario.correo,
      estado_verificacion: usuario.estado_verificacion
    }, status: :ok
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ::Domain::Errors::UsuarioNoEncontradoError
    render json: { error: "Usuario no encontrado" }, status: :not_found
  rescue ::Domain::Errors::CodigoVerificacionUsadoError
    render json: { error: "Cuenta ya verificada" }, status: :unprocessable_entity
  rescue ::Domain::Errors::CorreoVerificacionNoEnviadoError => e
    render json: { error: e.message }, status: :bad_gateway
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
