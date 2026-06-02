# frozen_string_literal: true

module Infrastructure
  module Mappers
    class AsignacionMapper
      # Converts an ORM AsignacionRecord to a Domain::Entities::Asignacion.
      def self.to_domain(record)
        Domain::Entities::Asignacion.new(
          id: record.id,
          empleado_id: record.empleado_id,
          obra_id: record.obra_id,
          estado: record.estado,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Asignacion to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          obra_id: entity.obra_id,
          estado: entity.estado
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
