# frozen_string_literal: true

module Infrastructure
  module Mappers
    class AlertaAusenciaMapper
      # Converts an ORM AlertaAusenciaRecord to a Domain::Entities::AlertaAusencia.
      def self.to_domain(record)
        return nil if record.nil?

        Domain::Entities::AlertaAusencia.new(
          id: record.id,
          empleado_id: record.empleado_id,
          obra_id: record.obra_id,
          empresa_id: record.empresa_id,
          fecha: record.fecha,
          estado: record.estado,
          evaluado_en: record.evaluado_en,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::AlertaAusencia to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          empleado_id: entity.empleado_id,
          obra_id: entity.obra_id,
          empresa_id: entity.empresa_id,
          fecha: entity.fecha,
          estado: entity.estado,
          evaluado_en: entity.evaluado_en
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
