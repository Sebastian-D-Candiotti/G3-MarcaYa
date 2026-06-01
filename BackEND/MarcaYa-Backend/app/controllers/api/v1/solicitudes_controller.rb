class Api::V1::SolicitudesController < ApplicationController

  # GET /api/v1/solicitudes
  def index
    solicitudes = Solicitud.where(estado: 'pendiente')

    resultado = solicitudes.map do |s|
        empleado = s.empleado
        obra = s.obra

        {
        id: s.id,
        estado: s.estado,

        empleado: {
            id: empleado.id,
            nombre: empleado.nombre,
            apellido: empleado.apellido,
            dni: empleado.dni
        },

        obra: {
            id: obra.id,
            nombre: obra.nombre
        }
        }
    end

    render json: resultado
    end
  # POST /api/v1/solicitudes
  def create
    solicitud = Solicitud.create!(
        empleado_id: params[:empleado_id],
        obra_id: params[:obra_id],
        estado: 'pendiente'
        )
    render json: solicitud
  end

  # PUT /api/v1/solicitudes/:id/aceptar
  def aceptar
    solicitud = Solicitud.find(params[:id])
    solicitud.update!(estado: 'aceptada')
    render json: solicitud
  end

  # PUT /api/v1/solicitudes/:id/rechazar
  def rechazar
    solicitud = Solicitud.find(params[:id])
    solicitud.update!(estado: 'rechazada')
    render json: solicitud
  end

  def obras_empleado
    solicitudes = Solicitud
                    .where(
                        empleado_id: params[:id],
                        estado: 'aceptada'
                    )
                    .distinct

    resultado = solicitudes.map do |s|
        obra = s.obra

        {
        id: obra.id,
        nombre: obra.nombre,
        latitud: obra.latitud,
        longitud: obra.longitud,
        radio: obra.radio
        }
    end

    render json: resultado
    end

    def historial_empleado
        solicitudes = Solicitud.where(
            empleado_id: params[:id]
        ).order(created_at: :desc)

        resultado = solicitudes.map do |s|
            obra = s.obra

            {
            id: s.id,
            estado: s.estado,
            fecha: s.created_at,
            obra: {
                id: obra.id,
                nombre: obra.nombre
            }
            }
        end

        render json: resultado
        end

end