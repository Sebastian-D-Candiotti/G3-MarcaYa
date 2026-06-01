# frozen_string_literal: true

module Infrastructure
  module Mappers
    class EmpresaMapper
      # Converts an ORM EmpresaRecord to a Domain::Entities::Empresa.
      def self.to_domain(record)
        Domain::Entities::Empresa.new(
          id: record.id,
          usuario_id: record.usuario_id,
          nombre_empresa: record.nombre_empresa,
          ruc: record.ruc,
          descripcion: record.descripcion,
          direccion: record.direccion,
          telefono: record.telefono,
          foto_url: record.foto_url,
          estado: record.estado,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Empresa to attributes hash for persistence.
      def self.to_record_attrs(entity)
        attrs = {
          usuario_id: entity.usuario_id,
          nombre_empresa: entity.nombre_empresa,
          ruc: entity.ruc,
          descripcion: entity.descripcion,
          direccion: entity.direccion,
          telefono: entity.telefono,
          foto_url: entity.foto_url,
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
