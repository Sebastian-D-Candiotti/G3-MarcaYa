class Api::V1::UsuariosController < Api::V1::BaseController
  # US-NUEVA-13: El endpoint de activación NO requiere JWT (viene de un correo)
  skip_before_action :authenticate!, only: [:activar_cuenta]

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

  # ════════════════════════════════════════════════════════════════
  # GET /api/v1/usuarios/:id/activar-cuenta?token=XXX
  # US-NUEVA-13: Activación de empresa vía enlace en correo electrónico.
  #
  # No requiere autenticación JWT (viene de un clic en el correo).
  # Valida un token HMAC-SHA256 firmado que contiene el user_id + timestamp.
  # Si es válido y no expirado (24h), activa la cuenta de la empresa.
  # Responde con HTML (no JSON) porque se abre en el navegador.
  # ════════════════════════════════════════════════════════════════
  def activar_cuenta
    token = params[:token].to_s.strip
    usuario_id = params[:id].to_i

    if token.blank?
      render html: render_activacion_html(
        exito: false,
        mensaje: "Enlace de activación inválido. No se proporcionó token."
      ), content_type: "text/html"
      return
    end

    # Validar token HMAC
    unless self.class.token_activacion_valido?(usuario_id, token)
      render html: render_activacion_html(
        exito: false,
        mensaje: "El enlace de activación ha expirado o es inválido. Solicita uno nuevo."
      ), content_type: "text/html"
      return
    end

    # Buscar usuario y empresa
    begin
      usuario = Rails.configuration.di.repos[:usuario].find_by_id!(usuario_id)
    rescue
      render html: render_activacion_html(
        exito: false,
        mensaje: "Usuario no encontrado."
      ), content_type: "text/html"
      return
    end

    unless usuario.es_empresa?
      render html: render_activacion_html(
        exito: false,
        mensaje: "Este enlace solo es válido para cuentas de empresa."
      ), content_type: "text/html"
      return
    end

    empresa_repo = Rails.configuration.di.repos[:empresa]
    empresa = empresa_repo.find_by_usuario_id(usuario.id)

    unless empresa
      render html: render_activacion_html(
        exito: false,
        mensaje: "No se encontró la empresa asociada a esta cuenta."
      ), content_type: "text/html"
      return
    end

    if empresa.estado == "activo"
      render html: render_activacion_html(
        exito: true,
        mensaje: "Tu cuenta ya estaba activa. Puedes usar la aplicación normalmente.",
        empresa_nombre: empresa.nombre_empresa
      ), content_type: "text/html"
      return
    end

    # ── Activar la cuenta ──────────────────────────────────────
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

    Rails.logger.info(
      "[ACTIVACIÓN] Empresa '#{empresa.nombre_empresa}' (ID: #{empresa.id}) " \
      "activada vía correo electrónico"
    )

    render html: render_activacion_html(
      exito: true,
      mensaje: "¡Tu cuenta ha sido activada exitosamente! Ya puedes ingresar a MarcaYa.",
      empresa_nombre: empresa.nombre_empresa
    ), content_type: "text/html"
  end

  # ── Generación y validación de tokens de activación ─────────

  # Genera un token HMAC-SHA256 firmado para activación por correo.
  # El token incluye el user_id y un timestamp redondeado a intervalos de 24h.
  # Esto permite que el token sea válido durante ~24-48 horas.
  def self.generar_token_activacion(usuario_id)
    secret = Rails.application.secret_key_base
    # Timestamp redondeado a períodos de 24h (epoch / 86400)
    periodo = (Time.current.to_i / 86400)
    data = "activar:#{usuario_id}:#{periodo}"
    OpenSSL::HMAC.hexdigest("SHA256", secret, data)
  end

  # Valida un token de activación.
  # Acepta tokens del período actual Y del período anterior (tolerancia de ~24-48h).
  def self.token_activacion_valido?(usuario_id, token)
    secret = Rails.application.secret_key_base
    periodo_actual = (Time.current.to_i / 86400)

    # Verificar período actual
    data_actual = "activar:#{usuario_id}:#{periodo_actual}"
    token_actual = OpenSSL::HMAC.hexdigest("SHA256", secret, data_actual)
    return true if ActiveSupport::SecurityUtils.secure_compare(token, token_actual)

    # Verificar período anterior (tolerancia de ~24h)
    data_anterior = "activar:#{usuario_id}:#{periodo_actual - 1}"
    token_anterior = OpenSSL::HMAC.hexdigest("SHA256", secret, data_anterior)
    ActiveSupport::SecurityUtils.secure_compare(token, token_anterior)
  end

  private

  # ── HTML de respuesta de activación (se muestra en el navegador) ──

  def render_activacion_html(exito:, mensaje:, empresa_nombre: nil)
    icono = exito ? "✅" : "❌"
    color = exito ? "#38A3A5" : "#EF4444"
    titulo = exito ? "¡Cuenta Activada!" : "Error de Activación"

    <<~HTML.html_safe
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{titulo} - MarcaYa</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0B4F7A 0%, #38A3A5 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
          }
          .card {
            background: white;
            border-radius: 20px;
            padding: 48px 36px;
            max-width: 440px;
            width: 100%;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
          }
          .icon { font-size: 64px; margin-bottom: 20px; }
          .title {
            font-size: 24px;
            font-weight: 700;
            color: #1F2937;
            margin-bottom: 12px;
          }
          .empresa {
            font-size: 14px;
            color: #{color};
            font-weight: 600;
            margin-bottom: 16px;
          }
          .message {
            font-size: 16px;
            color: #6B7280;
            line-height: 1.6;
            margin-bottom: 28px;
          }
          .badge {
            display: inline-block;
            background: #{color}15;
            color: #{color};
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            border: 1px solid #{color}40;
          }
          .footer {
            margin-top: 32px;
            font-size: 12px;
            color: #9CA3AF;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">#{icono}</div>
          <div class="title">#{titulo}</div>
          #{empresa_nombre ? "<div class='empresa'>#{empresa_nombre}</div>" : ""}
          <div class="message">#{mensaje}</div>
          <div class="badge">MarcaYa</div>
          <div class="footer">
            Puedes cerrar esta página y volver a la aplicación.
          </div>
        </div>
      </body>
      </html>
    HTML
  end

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
