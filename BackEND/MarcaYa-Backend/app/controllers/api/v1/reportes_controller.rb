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
end
