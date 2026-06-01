# frozen_string_literal: true

module Infrastructure
  module Mappers
    class UsuarioMapper
      # Converts an ORM UsuarioRecord to a Domain::Entities::Usuario.
      #
      # @param record [Infrastructure::Orm::UsuarioRecord] The ORM record
      # @return [Domain::Entities::Usuario] The domain entity
      def self.to_domain(record)
        Domain::Entities::Usuario.new(
          id: record.id,
          correo: record.correo,
          clave_hash: record.clave_hash,
          rol: record.rol,
          estado: record.estado,
          codigo_recuperacion: record.codigo_recuperacion,
          codigo_expira: record.codigo_expira,
          created_at: record.created_at,
          updated_at: record.updated_at
        )
      end

      # Converts a Domain::Entities::Usuario to attributes hash for persistence.
      #
      # @param entity [Domain::Entities::Usuario] The domain entity
      # @return [Hash] Attributes hash suitable for ActiveRecord create/update
      def self.to_record_attrs(entity)
        attrs = {
          correo: entity.correo,
          clave_hash: entity.clave_hash,
          rol: entity.rol.to_s,
          estado: entity.estado,
          codigo_recuperacion: entity.codigo_recuperacion,
          codigo_expira: entity.codigo_expira
        }
        attrs[:id] = entity.id if entity.id
        attrs[:created_at] = entity.created_at if entity.created_at
        attrs[:updated_at] = entity.updated_at if entity.updated_at
        attrs
      end
    end
  end
end
