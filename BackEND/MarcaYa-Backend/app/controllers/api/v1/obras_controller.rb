class Api::V1::ObrasController < ApplicationController

  def index
    render json: Obra.all
  end

  def show
    obra = Obra.find(params[:id])
    render json: obra
  end

  def create
    obra = Obra.new(obra_params)

    if obra.save
      render json: obra, status: :created
    else
      render json: {
        errors: obra.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    obra = Obra.find(params[:id])

    if obra.update(obra_params)
      render json: obra
    else
      render json: {
        errors: obra.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    obra = Obra.find(params[:id])
    obra.destroy

    render json: {
      mensaje: "Obra eliminada"
    }
  end

  private

  def obra_params
    params.permit(
      :empresa_id,
      :nombre,
      :descripcion_ubicacion,
      :latitud,
      :longitud,
      :radio_metros,
      :hora_inicio,
      :hora_fin,
      :tolerancia_entrada_min,
      :tolerancia_salida_min,
      :estado,
      :fecha_inicio,
      :fecha_fin,
      :direccion,
      :capacidad_empleados,
      :codigo_obra,
      :usuario_creador_id
    )
  end
end