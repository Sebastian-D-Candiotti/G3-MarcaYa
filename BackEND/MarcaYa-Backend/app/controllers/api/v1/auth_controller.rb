class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [
    :login, :registro, :verificar_otp, :solicitar_codigo,
    :verificar_codigo, :restablecer_contrasena,
    :verificar_cuenta, :reenviar_codigo_verificacion,
    :consultar_reniec
  ]

  def login
    resultado = Rails.configuration.di.auth_facade.login(
      correo: params[:correo],
      clave: params[:clave],
      device_id: params[:device_id]
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
    reenviar_verificacion_si_empresa
  rescue ::Domain::Errors::UsuarioInactivoError
    render json: { error: "Usuario no encontrado" }, status: :unauthorized
  end

  def registro
    resultado = Rails.configuration.di.auth_facade.registro(params.permit!.to_h.symbolize_keys)
    usuario = resultado[:usuario]
    ya_registrado = resultado[:ya_registrado] == true

    render json: {
      mensaje: ya_registrado \
        ? "Ya tienes un registro pendiente. Revisa tu correo para el nuevo codigo."
        : "Usuario registrado. Revisa tu correo para verificar la cuenta.",
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol.to_s,
      estado_verificacion: usuario.estado_verificacion,
      requiere_verificacion: resultado[:requiere_verificacion],
      ya_registrado: ya_registrado
    }, status: ya_registrado ? :ok : :created
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

  def solicitar_codigo
    resultado = Rails.configuration.di.auth_facade.solicitar_codigo(
      correo: params[:correo]
    )
    render json: resultado, status: :ok
  end

  def verificar_codigo
    resultado = Rails.configuration.di.auth_facade.verificar_codigo(
      correo: params[:correo],
      codigo: params[:codigo]
    )
    render json: resultado, status: :ok
  rescue ::Domain::Errors::CodigoInvalidoError
    render json: { error: "Código inválido. Intente de nuevo." }, status: :unauthorized
  rescue ::Domain::Errors::CodigoExpiradoError
    render json: { error: "El código ha expirado. Solicite uno nuevo." }, status: :unauthorized
  end

  def restablecer_contrasena
    resultado = Rails.configuration.di.auth_facade.restablecer_contrasena(
      verification_token: params[:verification_token],
      nueva_clave: params[:nueva_clave]
    )
    render json: resultado, status: :ok
  rescue ::Domain::Errors::TokenRecuperacionInvalidoError
    render json: { error: "Sesión de recuperación inválida. Comience de nuevo." }, status: :unauthorized
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

    # Si ya se verificó el OTP antes, no re-activar ni re-enviar al admin (idempotente)
    if empresa.otp_verificado == true
      render json: { mensaje: "OTP ya verificado. Tu cuenta está pendiente de aprobación por el administrador." }
      return
    end

    # Marcar OTP como verificado pero la empresa queda PENDIENTE hasta que el admin la active
    empresa_actualizada = Domain::Entities::Empresa.new(
      id: empresa.id,
      usuario_id: empresa.usuario_id,
      nombre_empresa: empresa.nombre_empresa,
      ruc: empresa.ruc,
      descripcion: empresa.descripcion,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      foto_url: empresa.foto_url,
      estado: "PENDIENTE",
      otp_verificado: true,
      created_at: empresa.created_at,
      updated_at: empresa.updated_at
    )
    empresa_repo.guardar(empresa_actualizada)

    # Enviar correo al admin de MarcaYa para que active la cuenta
    usuario = Rails.configuration.di.repos[:usuario].find_by_id!(empresa.usuario_id)
    admin_email = "marcaya3690@gmail.com"

    begin
      activation_token = Api::V1::UsuariosController.generar_token_activacion(usuario.id)
      UsuarioMailer.correo_solicitud_activacion_admin(
        admin_email,
        usuario.id,
        empresa.nombre_empresa,
        empresa.ruc,
        usuario.correo,
        activation_token
      ).deliver_now
    rescue StandardError => e
      Rails.logger.error("Error al enviar correo de activación al admin: #{e.message}")
    end

    render json: { mensaje: "OTP verificado. Tu cuenta está pendiente de aprobación por el administrador." }
  end

  def consultar_reniec
    dni = params[:dni].to_s.strip

    unless dni.match?(/\A\d{8}\z/)
      render json: { error: "El DNI debe tener exactamente 8 numeros" }, status: :unprocessable_entity
      return
    end

    datos = Infrastructure::Services::ReniecService.new.consultar(dni)

    if datos.nil?
      render json: { error: "No se encontraron datos en RENIEC para este DNI" }, status: :not_found
      return
    end

    render json: {
      nombres: datos[:nombres],
      apellido_paterno: datos[:apellido_paterno],
      apellido_materno: datos[:apellido_materno]
    }
  end

  private

  def reenviar_verificacion_si_empresa
    correo = params[:correo].to_s.strip
    usuario_repo = Rails.configuration.di.repos[:usuario]
    usuario = usuario_repo.find_by_correo(correo)

    if usuario&.es_empresa?
      empresa_repo = Rails.configuration.di.repos[:empresa]
      empresa = empresa_repo.find_by_usuario_id(usuario.id)

      if empresa
        # Generar y guardar nuevo OTP
        codigo_otp = rand(100000..999999).to_s
        expira_at = 15.minutes.from_now
        verificacion = Infrastructure::Orm::VerificacionRucRecord.find_or_initialize_by(ruc: empresa.ruc)
        verificacion.update!(codigo: codigo_otp, expira_at: expira_at)

        # Enviar correo con el OTP
        begin
          UsuarioMailer.correo_verificacion_ruc(usuario.correo, codigo_otp, empresa.nombre_empresa).deliver_now
        rescue StandardError => e
          Rails.logger.error("Error al reenviar OTP: #{e.message}")
        end

        correo_enmascarado = Domain::Services::SunatService.enmascarar_correo(usuario.correo)
        render json: {
          error: "Cuenta pendiente de verificación. Se envió un nuevo código a #{correo_enmascarado}",
          pendiente_verificacion: true,
          correo_enmascarado: correo_enmascarado,
          ruc: empresa.ruc,
          correo: usuario.correo
        }, status: :forbidden
        return
      end
    end

    render json: { error: "Cuenta pendiente de verificación" }, status: :forbidden
  end

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
