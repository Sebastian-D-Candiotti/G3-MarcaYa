# frozen_string_literal: true

module Serializer
  module ObraSerializer
    def self.as_json(obra)
      return nil if obra.nil?

      {
        id: obra.id,
        empresaId: obra.empresa_id,
        nombre: obra.nombre,
        codigoObra: obra.codigo_obra,
        direccion: obra.direccion,
        descripcionUbicacion: obra.descripcion_ubicacion,
        latitud: obra.latitud,
        longitud: obra.longitud,
        radioMetros: obra.radio_metros,
        horario: {
          inicio: obra.hora_inicio,
          fin: obra.hora_fin
        },
        tolerancia: {
          entrada: obra.tolerancia_entrada_min,
          salida: obra.tolerancia_salida_min
        },
        estado: obra.estado,
        fechaInicio: obra.fecha_inicio,
        fechaFin: obra.fecha_fin,
        capacidadEmpleados: obra.capacidad_empleados
      }
    end
  end
end
