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
end
