# frozen_string_literal: true

module Infrastructure
  module Mappers
    class SolicitudMapper
      # Converts an ORM SolicitudRecord to a Domain::Entities::Solicitud.
      def self.to_domain(record)
        Domain::Entities::Solicitud.new(
          id: record.id,
          empleado_id: record.empleado_id,
          empresa_id: record.empresa_id,
          estado: record.estado,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Solicitud to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          empresa_id: entity.empresa_id,
          estado: entity.estado.to_s
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
