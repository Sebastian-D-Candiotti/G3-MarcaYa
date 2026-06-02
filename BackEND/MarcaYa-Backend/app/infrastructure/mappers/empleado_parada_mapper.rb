# frozen_string_literal: true

module Infrastructure
  module Mappers
    class EmpleadoParadaMapper
      # Converts an ORM EmpleadoParadaRecord to a Domain::Entities::EmpleadoParada.
      def self.to_domain(record)
        return nil if record.nil?

        Domain::Entities::EmpleadoParada.new(
          id: record.id,
          empleado_id: record.empleado_id,
          parada_id: record.parada_id,
          activo: record.activo,
          estado: record.estado,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::EmpleadoParada to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          parada_id: entity.parada_id,
          activo: entity.activo,
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
