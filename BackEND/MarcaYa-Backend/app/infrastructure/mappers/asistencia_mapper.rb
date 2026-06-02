# frozen_string_literal: true

module Infrastructure
  module Mappers
    class AsistenciaMapper
      # Converts an ORM AsistenciaRecord to a Domain::Entities::RegistroAsistencia.
      def self.to_domain(record)
        return nil if record.nil?

        Domain::Entities::RegistroAsistencia.new(
          id: record.id,
          empleado_id: record.empleado_id,
          parada_id: record.parada_id,
          tipo_marcacion: record.tipo_marcacion,
          fecha_hora: record.fecha_hora,
          latitud_registrada: record.latitud_registrada,
          longitud_registrada: record.longitud_registrada,
          valida_gps: record.valida_gps,
          duracion_jornada: record.duracion_jornada,
          observaciones: record.observaciones,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::RegistroAsistencia to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          parada_id: entity.parada_id,
          tipo_marcacion: entity.tipo_marcacion,
          fecha_hora: entity.fecha_hora,
          latitud_registrada: entity.latitud_registrada,
          longitud_registrada: entity.longitud_registrada,
          valida_gps: entity.valida_gps,
          duracion_jornada: entity.duracion_jornada,
          observaciones: entity.observaciones
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
