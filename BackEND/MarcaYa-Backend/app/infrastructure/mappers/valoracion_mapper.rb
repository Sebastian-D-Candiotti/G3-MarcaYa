# frozen_string_literal: true

module Infrastructure
  module Mappers
    class ValoracionMapper
      # Converts an ORM ValoracionRecord to a Domain::Entities::Valoracion.
      def self.to_domain(record)
        Domain::Entities::Valoracion.new(
          id: record.id,
          empleado_id: record.empleado_id,
          empresa_id: record.empresa_id,
          puntuacion: record.puntuacion,
          comentario: record.comentario,
          created_at: record.created_at
        )
      end

      # Converts a Domain::Entities::Valoracion to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          empresa_id: entity.empresa_id,
          puntuacion: entity.puntuacion,
          comentario: entity.comentario
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs
      end
    end
  end
end
