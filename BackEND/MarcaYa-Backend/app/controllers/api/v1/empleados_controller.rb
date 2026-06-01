class Api::V1::EmpleadosController < ApplicationController

  # GET /api/v1/empleados/:id/obras
  def obras
  solicitudes = Solicitud
    .where(empleado_id: params[:id], estado: 'aceptada')
    .select(:obra_id)
    .distinct

  resultado = solicitudes.map do |s|
    obra = Obra.find_by(id: s.obra_id)
    next unless obra

    {
      id: obra.id,
      nombre: obra.nombre,
      estado: 'Activo',
      latitud: obra.latitud,
      longitud: obra.longitud,
      radio: obra.radio_metros
    }
  end.compact

  render json: resultado

  # GET /api/v1/empleados/actuales
  def actuales
    # Supongamos que `current_user` es tu empresa autenticada
    empresa = Empresa.find_by(usuario_id: params[:empresa_id]) # o current_user.id
    empleados = Empleado.where(empresa_id: empresa.id, estado: 'activo')

    render json: empleados.map { |e|
      {
        id: e.id,
        nombre: e.nombre,
        apellido: e.apellido,
        dni: e.dni,
        descripcion: e.descripcion,
        telefono: e.telefono,
      }
    }
  end
end

end