class Api::V1::EmpleadosController < Api::V1::BaseController

  # GET /api/v1/empleados/actuales
  def actuales
    empleados = Rails.configuration.di.empleado_facade.listar_actuales

    render json: empleados.map { |e|
      {
        id: e.id,
        nombre: e.nombre,
        apellido: e.apellido,
        dni: e.dni,
        descripcion: e.descripcion,
        telefono: e.telefono
      }
    }
  end

  # PUT /api/v1/empleados/:id
  def update
    empleado_repo = Rails.configuration.di.repos[:empleado]
    empleado = empleado_repo.find_by_id!(params[:id])

    attrs = {
      nombre: params[:nombre],
      apellido: params[:apellido],
      telefono: params[:telefono],
      descripcion: params[:descripcion]
    }.compact

    actualizado = Domain::Entities::Empleado.new(
      id: empleado.id,
      usuario_id: empleado.usuario_id,
      nombre: attrs[:nombre] || empleado.nombre,
      apellido: attrs[:apellido] || empleado.apellido,
      dni: empleado.dni,
      estado: empleado.estado,
      telefono: attrs[:telefono] || empleado.telefono,
      descripcion: attrs[:descripcion] || empleado.descripcion,
      foto_url: empleado.foto_url,
      created_at: empleado.created_at,
      updated_at: empleado.updated_at
    )

    empleado_actualizado = empleado_repo.guardar(actualizado)

    render json: {
      id: empleado_actualizado.id,
      nombre: empleado_actualizado.nombre,
      apellido: empleado_actualizado.apellido,
      telefono: empleado_actualizado.telefono,
      descripcion: empleado_actualizado.descripcion
    }
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Empleado no encontrado" }, status: :not_found
  rescue StandardError => e
    render json: { error: "Empleado no encontrado" }, status: :not_found
  end

  # PUT /api/v1/empleados/:id/desactivar
  def desactivar
    empleado_repo = Rails.configuration.di.repos[:empleado]
    empleado = empleado_repo.find_by_id!(params[:id])

    actualizado = Domain::Entities::Empleado.new(
      id: empleado.id,
      usuario_id: empleado.usuario_id,
      nombre: empleado.nombre,
      apellido: empleado.apellido,
      dni: empleado.dni,
      estado: "inactivo",
      telefono: empleado.telefono,
      descripcion: empleado.descripcion,
      foto_url: empleado.foto_url,
      created_at: empleado.created_at,
      updated_at: empleado.updated_at
    )

    empleado_repo.guardar(actualizado)

    render json: { mensaje: "Empleado desactivado correctamente" }
  rescue ::Domain::Errors::ValidacionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Empleado no encontrado" }, status: :not_found
  rescue StandardError => e
    render json: { error: "Empleado no encontrado" }, status: :not_found
  end

  # GET /api/v1/empleados/:id/asistencias
  def asistencias
    registros = Rails.configuration.di.repos[:asistencia].historial_por_empleado(params[:id])

    resultado = registros.map do |r|
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
        observaciones: r.observaciones
      }
    end

    render json: resultado
  end

  # GET /api/v1/empleados/:id/paradas
  def paradas
    empleado_paradas = ::Infrastructure::Orm::EmpleadoParadaRecord
      .where(empleado_id: params[:id], activo: true)
      .includes(:parada)

    resultado = empleado_paradas.map do |ep|
      parada = ep.parada
      {
        id: parada.id,
        nombre: parada.nombre,
        latitud: parada.latitud,
        longitud: parada.longitud,
        radioMetros: parada.radio_metros,
        obraId: parada.obra_id,
        estado: parada.estado
      }
    end

    render json: resultado
  end
end
