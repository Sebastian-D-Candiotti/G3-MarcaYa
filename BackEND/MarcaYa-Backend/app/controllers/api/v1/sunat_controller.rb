# frozen_string_literal: true

class Api::V1::SunatController < Api::V1::BaseController
  skip_before_action :authenticate!, only: [:index, :enviar_codigo, :consulta, :validar_ruc_unico]

  # GET /api/v1/sunat/empresas
  def index
    empresas = Domain::Services::SunatService.listar_todas
    
    render json: empresas.map { |e|
      {
        ruc: e.ruc,
        razon_social: e.razon_social,
        correo_enmascarado: Domain::Services::SunatService.enmascarar_correo(e.correo_oficial)
      }
    }
  end

  # GET /api/v1/sunat/consulta
  def consulta
    ruc = params[:ruc]
    if ruc.blank?
      render json: { error: "El RUC es obligatorio" }, status: :unprocessable_entity
      return
    end

    empresa_sunat = Domain::Services::SunatService.buscar_por_ruc(ruc)
    if empresa_sunat.nil?
      render json: { error: "Empresa no encontrada en los registros de SUNAT" }, status: :not_found
      return
    end

    render json: {
      ruc: empresa_sunat.ruc,
      razon_social: empresa_sunat.razon_social,
      correo_enmascarado: Domain::Services::SunatService.enmascarar_correo(empresa_sunat.correo_oficial)
    }
  end

  # POST /api/v1/sunat/enviar-codigo
  def enviar_codigo
    ruc = params[:ruc]
    correo = params[:correo]

    if ruc.blank?
      render json: { error: "El RUC es obligatorio" }, status: :unprocessable_entity
      return
    end

    empresa_sunat = Domain::Services::SunatService.buscar_por_ruc(ruc)
    destinatario_correo = nil
    razon_social = ""

    if empresa_sunat.nil?
      empresa_db = Rails.configuration.di.repos[:empresa].find_by_ruc(ruc) rescue nil
      if empresa_db.nil? && correo.blank?
        render json: { error: "Empresa no encontrada en los registros de SUNAT y correo no proporcionado" }, status: :not_found
        return
      end
      destinatario_correo = correo.presence || (empresa_db ? Rails.configuration.di.repos[:usuario].find_by_id!(empresa_db.usuario_id).correo : nil) rescue nil
      if destinatario_correo.blank?
        render json: { error: "No se pudo determinar el correo destinatario" }, status: :unprocessable_entity
        return
      end
      razon_social = empresa_db&.nombre_empresa || "Nueva Empresa Manual"
    else
      destinatario_correo = correo.presence || empresa_sunat.correo_oficial
      razon_social = empresa_sunat.razon_social
    end

    # Generar código de 6 dígitos
    codigo = rand(100000..999999).to_s
    expira_at = 15.minutes.from_now

    # Guardar o actualizar verificación
    verificacion = Infrastructure::Orm::VerificacionRucRecord.find_or_initialize_by(ruc: ruc)
    verificacion.update!(
      codigo: codigo,
      expira_at: expira_at
    )

    # Imprimir en logs/consola
    mensaje_consola = "\n========================================\n" \
                      "[SUNAT MOCK MAIL] Código enviado a: #{destinatario_correo}\n" \
                      "RUC: #{ruc} | Empresa: #{razon_social}\n" \
                      "CÓDIGO DE VERIFICACIÓN: #{codigo}\n" \
                      "========================================\n"
    puts mensaje_consola
    Rails.logger.info(mensaje_consola)

    # Enviar el correo usando UsuarioMailer
    begin
      if defined?(UsuarioMailer)
        UsuarioMailer.correo_verificacion_ruc(destinatario_correo, codigo, razon_social).deliver_now
      end
    rescue StandardError => e
      Rails.logger.error("Error al enviar correo de verificacion de RUC: #{e.message}")
    end

    render json: {
      mensaje: "Código enviado correctamente",
      correo_enmascarado: Domain::Services::SunatService.enmascarar_correo(destinatario_correo),
      codigo_debug: codigo
    }
  end

  # GET /api/v1/sunat/validar-ruc-unico
  def validar_ruc_unico
    ruc = params[:ruc].to_s.strip
    if ruc.blank?
      render json: { error: "El RUC es obligatorio" }, status: :unprocessable_entity
      return
    end

    empresa_repo = Rails.configuration.di.repos[:empresa]
    existe = empresa_repo.exists_by_ruc?(ruc)

    render json: { unico: !existe }
  end
end
