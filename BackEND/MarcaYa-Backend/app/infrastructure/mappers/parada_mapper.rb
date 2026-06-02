# frozen_string_literal: true

module Infrastructure
  module Mappers
    class ParadaMapper
      # Converts an ORM ParadaRecord to a Domain::Entities::Parada.
      def self.to_domain(record)
        return nil if record.nil?

        Domain::Entities::Parada.new(
          id: record.id,
          obra_id: record.obra_id,
          nombre: record.nombre,
          latitud: record.latitud,
          longitud: record.longitud,
          radio_metros: record.radio_metros,
          estado: record.estado,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Parada to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          obra_id: entity.obra_id,
          nombre: entity.nombre,
          latitud: entity.latitud,
          longitud: entity.longitud,
          radio_metros: entity.radio_metros,
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
