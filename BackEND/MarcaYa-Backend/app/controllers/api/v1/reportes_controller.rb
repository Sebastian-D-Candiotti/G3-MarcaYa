class Api::V1::ReportesController < Api::V1::BaseController
  # GET /api/v1/reportes/asistencia
  def asistencia
    records = ::Infrastructure::Orm::AsistenciaRecord.all

    if params[:empleado_id].present?
      records = records.where(empleado_id: params[:empleado_id])
    end

    if params[:parada_id].present?
      records = records.where(parada_id: params[:parada_id])
    end

    if params[:fecha_inicio].present?
      records = records.where("fecha_hora >= ?", Date.parse(params[:fecha_inicio]).beginning_of_day)
    end

    if params[:fecha_fin].present?
      records = records.where("fecha_hora <= ?", Date.parse(params[:fecha_fin]).end_of_day)
    end

    if params[:obra_id].present?
      records = records.joins(:parada).where(paradas: { obra_id: params[:obra_id] })
    end

    records = records.order(fecha_hora: :desc)

    resultado = records.map do |r|
      {
        id: r.id,
        empleadoId: r.empleado_id,
        paradaId: r.parada_id,
        tipoMarcacion: r.tipo_marcacion,
        fechaHora: r.fecha_hora&.iso8601,
        latitudRegistrada: r.latitud_registrada,
        longitudRegistrada: r.longitud_registrada,
        validaGps: r.valida_gps,
        duracionJornada: r.duracion_jornada,
        observaciones: r.observaciones,
        createdAt: r.created_at,
        updatedAt: r.updated_at
      }
    end

    render json: resultado
  rescue Date::Error => e
    render json: { error: "Formato de fecha inválido: #{e.message}" }, status: :unprocessable_entity
  end

  # ════════════════════════════════════════════════════════════════
  # POST /api/v1/reportes/informe-ia
  # US-NUEVA-06: Genera informe ejecutivo con IA (Google Gemini)
  #
  # Params opcionales:
  #   - fecha_inicio (string, formato YYYY-MM-DD)
  #   - fecha_fin    (string, formato YYYY-MM-DD)
  #
  # Flujo:
  #   1. Filtra asistencias de la empresa autenticada
  #   2. Agrupa datos de forma ANÓNIMA (sin nombres ni IDs)
  #   3. Construye prompt con datos tabulares
  #   4. Envía a Gemini API
  #   5. Retorna informe + metadatos
  # ════════════════════════════════════════════════════════════════
  def informe_ia
    api_key = ENV["GEMINI_API_KEY"]
    if api_key.blank?
      return render json: {
        error: "La clave de API de Gemini no está configurada. Agrega GEMINI_API_KEY en el archivo .env del backend."
      }, status: :service_unavailable
    end

    # ── 1. Determinar período ─────────────────────────────────
    fecha_fin   = params[:fecha_fin].present?    ? Date.parse(params[:fecha_fin])    : Date.today
    fecha_inicio = params[:fecha_inicio].present? ? Date.parse(params[:fecha_inicio]) : fecha_fin - 30.days

    # ── 2. Obtener asistencias de la empresa ──────────────────
    empresa = current_user.empresa
    unless empresa
      return render json: { error: "Solo usuarios de tipo empresa pueden generar informes." }, status: :forbidden
    end

    # IDs de las obras de esta empresa
    obra_ids = empresa.obras.pluck(:id)

    if obra_ids.empty?
      return render json: {
        error: "No hay obras registradas para esta empresa."
      }, status: :unprocessable_entity
    end

    # IDs de las paradas de esas obras
    parada_ids = ::Infrastructure::Orm::ParadaRecord
                   .where(obra_id: obra_ids)
                   .pluck(:id)

    records = ::Infrastructure::Orm::AsistenciaRecord
                .where(parada_id: parada_ids)
                .where("fecha_hora >= ? AND fecha_hora <= ?",
                       fecha_inicio.beginning_of_day,
                       fecha_fin.end_of_day)
                .includes(:parada)

    if records.empty?
      return render json: {
        error: "No hay registros de asistencia en el período seleccionado (#{fecha_inicio} a #{fecha_fin})."
      }, status: :unprocessable_entity
    end

    # ── 3. Agregar datos ANÓNIMOS ─────────────────────────────
    datos_anonimos = agregar_datos_anonimos(records, obra_ids)

    # ── 4. Construir prompt ───────────────────────────────────
    prompt = construir_prompt_informe(datos_anonimos, fecha_inicio, fecha_fin)

    # ── 5. Llamar a Gemini API ────────────────────────────────
    informe_texto = llamar_gemini(api_key, prompt)

    render json: {
      informe: informe_texto,
      periodo: {
        inicio: fecha_inicio.iso8601,
        fin: fecha_fin.iso8601
      },
      datos_analizados: {
        total_registros: datos_anonimos[:total_registros],
        total_empleados: datos_anonimos[:total_empleados],
        total_paradas: datos_anonimos[:total_paradas]
      }
    }
  rescue Date::Error => e
    render json: { error: "Formato de fecha inválido: #{e.message}" }, status: :unprocessable_entity
  rescue GeminiApiError => e
    render json: { error: "Error al comunicarse con la IA: #{e.message}" }, status: :bad_gateway
  rescue => e
    Rails.logger.error("InformeIA error: #{e.class} — #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    render json: { error: "Error interno al generar el informe." }, status: :internal_server_error
  end

  private

  # ── Excepción personalizada para errores de Gemini ──────────
  class GeminiApiError < StandardError; end

  # ── Agrupar datos de forma anónima ──────────────────────────
  def agregar_datos_anonimos(records, obra_ids)
    empleados_unicos = records.map(&:empleado_id).uniq
    paradas_unicas   = records.map(&:parada_id).uniq

    # Mapa parada_id → nombre de parada (para el resumen)
    parada_nombres = ::Infrastructure::Orm::ParadaRecord
                       .where(id: paradas_unicas)
                       .pluck(:id, :nombre)
                       .to_h

    # Obra nombres
    obra_nombres = ::Infrastructure::Orm::ObraRecord
                     .where(id: obra_ids)
                     .pluck(:id, :nombre)
                     .to_h

    # Parada → obra mapping
    parada_obra = ::Infrastructure::Orm::ParadaRecord
                    .where(id: paradas_unicas)
                    .pluck(:id, :obra_id)
                    .to_h

    # ── Agrupación por fecha ──────────────────────────────────
    por_fecha = records.group_by { |r| r.fecha_hora&.to_date }.sort_by(&:first)
    resumen_diario = por_fecha.map do |fecha, regs|
      entradas = regs.count { |r| r.tipo_marcacion&.downcase&.include?("entrada") }
      salidas  = regs.count { |r| r.tipo_marcacion&.downcase&.include?("salida") }
      gps_ok   = regs.count { |r| r.valida_gps == true }
      duraciones = regs.filter_map { |r| r.duracion_jornada&.to_f }.select(&:positive?)

      {
        fecha: fecha&.iso8601 || "sin_fecha",
        total_marcaciones: regs.size,
        entradas: entradas,
        salidas: salidas,
        empleados_activos: regs.map(&:empleado_id).uniq.size,
        gps_valido_pct: regs.size > 0 ? (gps_ok * 100.0 / regs.size).round(1) : 0,
        duracion_promedio_hrs: duraciones.any? ? (duraciones.sum / duraciones.size).round(2) : nil
      }
    end

    # ── Agrupación por parada ─────────────────────────────────
    por_parada = records.group_by(&:parada_id)
    resumen_paradas = por_parada.map do |parada_id, regs|
      entradas = regs.count { |r| r.tipo_marcacion&.downcase&.include?("entrada") }
      gps_ok   = regs.count { |r| r.valida_gps == true }
      duraciones = regs.filter_map { |r| r.duracion_jornada&.to_f }.select(&:positive?)

      obra_id = parada_obra[parada_id]
      {
        parada: parada_nombres[parada_id] || "Parada #{parada_id}",
        obra: obra_nombres[obra_id] || "Obra #{obra_id}",
        total_marcaciones: regs.size,
        entradas: entradas,
        empleados_unicos: regs.map(&:empleado_id).uniq.size,
        gps_valido_pct: regs.size > 0 ? (gps_ok * 100.0 / regs.size).round(1) : 0,
        duracion_promedio_hrs: duraciones.any? ? (duraciones.sum / duraciones.size).round(2) : nil
      }
    end

    {
      total_registros: records.size,
      total_empleados: empleados_unicos.size,
      total_paradas: paradas_unicas.size,
      resumen_diario: resumen_diario,
      resumen_paradas: resumen_paradas
    }
  end

  # ── Construir prompt para Gemini ────────────────────────────
  def construir_prompt_informe(datos, fecha_inicio, fecha_fin)
    diario_tabla = datos[:resumen_diario].map do |d|
      "| #{d[:fecha]} | #{d[:total_marcaciones]} | #{d[:entradas]} | #{d[:salidas]} | #{d[:empleados_activos]} | #{d[:gps_valido_pct]}% | #{d[:duracion_promedio_hrs] || 'N/A'} |"
    end.join("\n")

    paradas_tabla = datos[:resumen_paradas].map do |p|
      "| #{p[:parada]} | #{p[:obra]} | #{p[:total_marcaciones]} | #{p[:entradas]} | #{p[:empleados_unicos]} | #{p[:gps_valido_pct]}% | #{p[:duracion_promedio_hrs] || 'N/A'} |"
    end.join("\n")

    <<~PROMPT
      Eres un analista de recursos humanos experto en gestión de asistencia laboral.
      Genera un informe ejecutivo en español basado en los siguientes datos ANÓNIMOS de asistencia de una empresa.

      ## Contexto
      - Período analizado: #{fecha_inicio} a #{fecha_fin}
      - Total de registros: #{datos[:total_registros]}
      - Total de empleados activos: #{datos[:total_empleados]}
      - Total de paradas/ubicaciones: #{datos[:total_paradas]}

      ## Datos diarios (anónimos)
      | Fecha | Marcaciones | Entradas | Salidas | Empleados activos | GPS válido % | Duración promedio (hrs) |
      |-------|-------------|----------|---------|-------------------|--------------|------------------------|
      #{diario_tabla}

      ## Datos por parada/ubicación (anónimos)
      | Parada | Obra | Marcaciones | Entradas | Empleados únicos | GPS válido % | Duración promedio (hrs) |
      |--------|------|-------------|----------|------------------|--------------|------------------------|
      #{paradas_tabla}

      ## Instrucciones
      Genera un informe ejecutivo profesional en español con las siguientes secciones:

      1. **Resumen Ejecutivo**: Un párrafo breve con los hallazgos principales.
      2. **Análisis de Tendencias de Puntualidad**: Identificar patrones en los datos diarios (días con más/menos asistencia, tendencias de GPS válido, etc.)
      3. **Rendimiento por Ubicación**: Comparar el desempeño entre paradas/obras.
      4. **Alertas y Observaciones**: Señalar posibles problemas (baja validación GPS, empleados sin salida registrada, etc.)
      5. **Sugerencias de Gestión**: 3-5 recomendaciones concretas y accionables para mejorar la gestión de asistencia.

      Usa formato Markdown. Sé conciso pero informativo. No inventes datos que no estén en la tabla.
    PROMPT
  end

  # ── Llamada a Google Gemini API ─────────────────────────────
  def llamar_gemini(api_key, prompt)
    require "net/http"
    require "json"

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{api_key}")

    body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 4096
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 15
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(response.body) rescue {}
      error_msg = parsed.dig("error", "message") || "HTTP #{response.code}"
      Rails.logger.error("Gemini API error: #{response.code} — #{error_msg}")
      raise GeminiApiError, error_msg
    end

    parsed = JSON.parse(response.body)
    texto = parsed.dig("candidates", 0, "content", "parts", 0, "text")

    if texto.blank?
      raise GeminiApiError, "La IA no generó una respuesta válida."
    end

    texto
  end
end
