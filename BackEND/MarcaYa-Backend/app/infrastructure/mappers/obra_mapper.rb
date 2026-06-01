# frozen_string_literal: true

module Infrastructure
  module Mappers
    class ObraMapper
      # Converts an ORM ObraRecord to a Domain::Entities::Obra.
      def self.to_domain(record)
        Domain::Entities::Obra.new(
          id: record.id,
          empresa_id: record.empresa_id,
          nombre: record.nombre,
          codigo_obra: record.codigo_obra,
          direccion: record.direccion,
          descripcion_ubicacion: record.descripcion_ubicacion,
          latitud: record.latitud,
          longitud: record.longitud,
          radio_metros: record.radio_metros,
          hora_inicio: record.hora_inicio,
          hora_fin: record.hora_fin,
          tolerancia_entrada_min: record.tolerancia_entrada_min,
          tolerancia_salida_min: record.tolerancia_salida_min,
          estado: record.estado,
          fecha_inicio: record.fecha_inicio,
          fecha_fin: record.fecha_fin,
          capacidad_empleados: record.capacidad_empleados,
          usuario_creador_id: record.usuario_creador_id,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Obra to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empresa_id: entity.empresa_id,
          nombre: entity.nombre,
          codigo_obra: entity.codigo_obra,
          direccion: entity.direccion,
          descripcion_ubicacion: entity.descripcion_ubicacion,
          latitud: entity.latitud,
          longitud: entity.longitud,
          radio_metros: entity.radio_metros,
          hora_inicio: entity.hora_inicio,
          hora_fin: entity.hora_fin,
          tolerancia_entrada_min: entity.tolerancia_entrada_min,
          tolerancia_salida_min: entity.tolerancia_salida_min,
          estado: entity.estado,
          fecha_inicio: entity.fecha_inicio,
          fecha_fin: entity.fecha_fin,
          capacidad_empleados: entity.capacidad_empleados,
          usuario_creador_id: entity.usuario_creador_id
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
