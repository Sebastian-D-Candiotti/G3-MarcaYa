class Api::V1::SolicitudesController < Api::V1::BaseController

  # GET /api/v1/solicitudes
  def index
    solicitudes = Rails.configuration.di.solicitud_facade.listar

    resultado = solicitudes.map do |s|
      empleado = Rails.configuration.di.repos[:empleado].find_by_id!(s.empleado_id) rescue nil
      empresa = Rails.configuration.di.repos[:empresa].find_by_id!(s.empresa_id) rescue nil

      {
        id: s.id,
        estado: s.estado.to_s,
        empleado: {
          id: empleado&.id,
          usuario_id: empleado&.usuario_id,
          nombre: empleado&.nombre,
          apellido: empleado&.apellido,
          dni: empleado&.dni
        },
        empresa: {
          id: empresa&.id,
          nombre: empresa&.nombre_empresa
        }
      }
    end

    render json: resultado
  end

  # POST /api/v1/solicitudes
  def create
    solicitud = Rails.configuration.di.solicitud_facade.crear(
      empleado_id: params[:empleado_id],
      empresa_id: params[:empresa_id]
    )

    render json: Serializer::SolicitudSerializer.as_json(solicitud)
  rescue ::Domain::Errors::ValidacionError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # PUT /api/v1/solicitudes/:id/aceptar
  def aceptar
    solicitud = Rails.configuration.di.solicitud_facade.aceptar(
      id: params[:id],
      obra_id: params[:obra_id]
    )
    render json: Serializer::SolicitudSerializer.as_json(solicitud)
  rescue ::Domain::Errors::SolicitudNoEncontradaError
    render json: { error: "Solicitud no encontrada" }, status: :not_found
  rescue ::Domain::Errors::TransicionEstadoInvalidaError, ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PUT /api/v1/solicitudes/:id/rechazar
  def rechazar
    solicitud = Rails.configuration.di.solicitud_facade.rechazar(id: params[:id])
    render json: Serializer::SolicitudSerializer.as_json(solicitud)
  rescue ::Domain::Errors::SolicitudNoEncontradaError
    render json: { error: "Solicitud no encontrada" }, status: :not_found
  rescue ::Domain::Errors::TransicionEstadoInvalidaError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /api/v1/solicitudes/:id
  def show
    solicitud = Rails.configuration.di.repos[:solicitud].find_by_id!(params[:id])

    empleado = Rails.configuration.di.repos[:empleado].find_by_id!(solicitud.empleado_id) rescue nil
    empresa = Rails.configuration.di.repos[:empresa].find_by_id!(solicitud.empresa_id) rescue nil

    render json: {
      id: solicitud.id,
      estado: solicitud.estado.to_s,
      empleado: {
        id: empleado&.id,
        usuario_id: empleado&.usuario_id,
        nombre: empleado&.nombre,
        apellido: empleado&.apellido,
        dni: empleado&.dni
      },
      empresa: {
        id: empresa&.id,
        nombre: empresa&.nombre_empresa
      }
    }
  rescue ::Domain::Errors::SolicitudNoEncontradaError
    render json: { error: "Solicitud no encontrada" }, status: :not_found
  end

  # GET /api/v1/solicitudes/mis-solicitudes
  def mis_solicitudes
    empleado = Rails.configuration.di.repos[:empleado].find_by_usuario_id(current_user.id)
    return render json: [] unless empleado

    solicitudes = Rails.configuration.di.repos[:solicitud].listar_por_empleado(empleado.id)
                                                     .sort_by(&:created_at)
                                                     .reverse

    resultado = solicitudes.map do |s|
      empresa = Rails.configuration.di.repos[:empresa].find_by_id!(s.empresa_id) rescue nil

      {
        id: s.id,
        estado: s.estado.to_s,
        fecha: s.created_at,
        empresa: {
          id: empresa&.id,
          nombre: empresa&.nombre_empresa
        }
      }
    end

    render json: resultado
  end

  # GET /api/v1/empleados/:id/obras
  def obras_empleado
    obras = Rails.configuration.di.empleado_facade.obtener_obras(empleado_id: params[:id])

    resultado = obras.map do |o|
      {
        id: o.id,
        nombre: o.nombre,
        empresa_id: o.empresa_id,
        latitud: o.latitud,
        longitud: o.longitud,
        radio: o.radio_metros,
        hora_inicio: o.hora_inicio&.strftime("%H:%M") || "08:00",
        hora_fin: o.hora_fin&.strftime("%H:%M") || "18:00"
      }
    end

    render json: resultado
  rescue ::Domain::Errors::UsuarioNoEncontradoError,
         ::Domain::Errors::ObraNoEncontradaError
    render json: { error: "Empleado no encontrado" }, status: :not_found
  end

  # GET /api/v1/empleados/:id/historial_solicitudes
  def historial_empleado
    solicitudes = Rails.configuration.di.repos[:solicitud].listar_por_empleado(params[:id])
                                                    .sort_by(&:created_at)
                                                    .reverse

    resultado = solicitudes.map do |s|
      empresa = Rails.configuration.di.repos[:empresa].find_by_id!(s.empresa_id) rescue nil

      {
        id: s.id,
        estado: s.estado.to_s,
        fecha: s.created_at,
        empresa: {
          id: empresa&.id,
          nombre: empresa&.nombre_empresa
        }
      }
    end

    render json: resultado
  end
end
