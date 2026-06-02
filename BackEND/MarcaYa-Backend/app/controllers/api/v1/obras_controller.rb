class Api::V1::ObrasController < Api::V1::BaseController

  # GET /api/v1/obras
  def index
    obras = Rails.configuration.di.obra_facade.listar
    render json: obras.map { |o| Serializer::ObraSerializer.as_json(o) }
  end

  # GET /api/v1/obras/:id
  def show
    obra = Rails.configuration.di.obra_facade.obtener(id: params[:id])
    render json: Serializer::ObraSerializer.as_json(obra)
  rescue ::Domain::Errors::ObraNoEncontradaError
    render json: { error: "Obra no encontrada" }, status: :not_found
  end

  # POST /api/v1/obras
  def create
    obra = Rails.configuration.di.obra_facade.crear(obra_params)
    render json: Serializer::ObraSerializer.as_json(obra), status: :created
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # PUT /api/v1/obras/:id
  def update
    obra = Rails.configuration.di.obra_facade.actualizar(id: params[:id], params: obra_params)
    render json: Serializer::ObraSerializer.as_json(obra)
  rescue ::Domain::Errors::ObraNoEncontradaError
    render json: { error: "Obra no encontrada" }, status: :not_found
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # DELETE /api/v1/obras/:id
  def destroy
    Rails.configuration.di.obra_facade.eliminar(id: params[:id])
    render json: { mensaje: "Obra eliminada" }
  rescue ::Domain::Errors::ObraNoEncontradaError
    render json: { error: "Obra no encontrada" }, status: :not_found
  end

  # GET /api/v1/obras/:id/paradas
  def index_paradas
    paradas = Rails.configuration.di.parada_facade.listar_por_obra(obra_id: params[:id])
    render json: paradas.map { |p| Serializer::ParadaSerializer.as_json(p) }
  rescue ::Domain::Errors::ObraNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  end

  # POST /api/v1/obras/:id/paradas
  def create_parada
    parada = Rails.configuration.di.parada_facade.crear(
      obra_id: params[:id],
      params: parada_params
    )
    render json: Serializer::ParadaSerializer.as_json(parada), status: :created
  rescue ::Domain::Errors::ObraNoEncontradaError => e
    render json: { error: e.message }, status: :not_found
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def parada_params
    params.permit(:nombre, :latitud, :longitud, :radio_metros, :estado)
  end

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
