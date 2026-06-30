# frozen_string_literal: true

module Infrastructure
  module Mappers
    class EmpleadoMapper
      # Converts an ORM EmpleadoRecord to a Domain::Entities::Empleado.
      def self.to_domain(record)
        Domain::Entities::Empleado.new(
          id: record.id,
          usuario_id: record.usuario_id,
          nombre: record.nombre,
          apellido: record.apellido,
          dni: record.dni,
          estado: record.estado,
          telefono: record.telefono,
          descripcion: record.descripcion,
          foto_url: record.foto_url,
          created_at: record.created_at,
          updated_at: record.updated_at,
          device_id: record.device_id
        )
      end

      # Converts a Domain::Entities::Empleado to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          usuario_id: entity.usuario_id,
          nombre: entity.nombre,
          apellido: entity.apellido,
          dni: entity.dni,
          estado: entity.estado,
          telefono: entity.telefono,
          descripcion: entity.descripcion,
          foto_url: entity.foto_url,
          device_id: entity.device_id
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
