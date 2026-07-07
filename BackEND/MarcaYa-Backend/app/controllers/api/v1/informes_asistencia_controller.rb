# frozen_string_literal: true

class Api::V1::InformesAsistenciaController < Api::V1::BaseController
  before_action :require_empresa_or_admin!

  # GET /api/v1/informes/asistencia
  def index
    result = Application::UseCases::InformesAsistencia::ListarHistorial.new.call(
      current_user: current_user,
      params: params
    )
    render_result(result)
  end

  # POST /api/v1/informes/asistencia/generar
  def generar
    result = Application::UseCases::InformesAsistencia::GenerarVistaPrevia.new.call(
      current_user: current_user,
      params: params
    )
    render_result(result)
  end

  # POST /api/v1/informes/asistencia/cerrar-mes
  def cerrar_mes
    result = Application::UseCases::InformesAsistencia::CerrarMes.new.call(
      current_user: current_user,
      params: params
    )
    render_result(result)
  end

  # GET /api/v1/informes/asistencia/:id
  def show
    result = Application::UseCases::InformesAsistencia::ObtenerDetalle.new.call(
      current_user: current_user,
      id: params[:id]
    )
    render_result(result)
  end

  # GET /api/v1/informes/asistencia/:id/pdf
  def pdf
    result = Application::UseCases::InformesAsistencia::DescargarPdf.new.call(
      current_user: current_user,
      id: params[:id]
    )

    unless result.success?
      render_result(result)
      return
    end

    send_data result.data[:bytes],
              filename: result.data[:filename],
              type: result.data[:content_type],
              disposition: "attachment"
  end

  private

  def require_empresa_or_admin!
    return if performed?
    return if %w[empresa admin].include?(current_user&.rol)

    render json: { error: "No autorizado" }, status: :forbidden
  end

  def render_result(result)
    if result.success?
      render json: result.data, status: result.status
    else
      render json: { error: result.error, details: result.data }.compact, status: result.status
    end
  end
end
