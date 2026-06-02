# frozen_string_literal: true

class Api::V1::ParadasController < Api::V1::BaseController

  # GET /api/v1/paradas/:id
  def show
    parada = Rails.configuration.di.parada_facade.obtener(id: params[:id])
    render json: Serializer::ParadaSerializer.as_json(parada)
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  end

  # PUT /api/v1/paradas/:id
  def update
    parada = Rails.configuration.di.parada_facade.actualizar(id: params[:id], params: update_params)
    render json: Serializer::ParadaSerializer.as_json(parada)
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # DELETE /api/v1/paradas/:id
  def destroy
    Rails.configuration.di.parada_facade.eliminar(id: params[:id])
    render json: { mensaje: "Parada eliminada" }
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  end

  # GET /api/v1/paradas/:id/empleados
  def index_empleados
    empleados = Rails.configuration.di.parada_facade.listar_empleados(parada_id: params[:id])
    render json: empleados.map { |emp| Serializer::EmpleadoSerializer.as_json(emp) }
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  end

  # POST /api/v1/paradas/:id/empleados
  def asignar_empleado
    Rails.configuration.di.parada_facade.asignar_empleado(
      parada_id: params[:id],
      empleado_id: params[:empleado_id]
    )
    render json: { mensaje: "Empleado asignado correctamente" }, status: :created
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # DELETE /api/v1/paradas/:id/empleados/:empleado_id
  def desasignar_empleado
    Rails.configuration.di.parada_facade.desasignar_empleado(
      parada_id: params[:id],
      empleado_id: params[:empleado_id]
    )
    render json: { mensaje: "Empleado desasignado correctamente" }
  rescue ::Domain::Errors::ParadaNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def update_params
    params.permit(:nombre, :latitud, :longitud, :radio_metros, :estado)
  end
end
