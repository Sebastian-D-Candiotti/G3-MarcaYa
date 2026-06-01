# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IUsuarioRepository
    class ArUsuarioRepository
      class << self
        def find_by_id!(id)
          record = ::Infrastructure::Orm::UsuarioRecord.find(id)
          ::Infrastructure::Mappers::UsuarioMapper.to_domain(record)
        rescue ActiveRecord::RecordNotFound
          raise Domain::Errors::UsuarioNoEncontradoError,
                "Usuario con id #{id} no encontrado"
        end

        def find_by_correo(correo)
          record = ::Infrastructure::Orm::UsuarioRecord.find_by(correo: correo)
          return nil unless record

          ::Infrastructure::Mappers::UsuarioMapper.to_domain(record)
        end

        def guardar(usuario)
          if usuario.id
            update_existing(usuario)
          else
            create_new(usuario)
          end
        rescue ActiveRecord::RecordNotFound
          raise Domain::Errors::UsuarioNoEncontradoError,
                "Usuario con id #{usuario.id} no encontrado"
        end

        def exists_by_correo?(correo)
          ::Infrastructure::Orm::UsuarioRecord.exists?(correo: correo)
        end

        private

        def create_new(usuario)
          attrs = ::Infrastructure::Mappers::UsuarioMapper.to_record_attrs(usuario)
          clave_hash = attrs.delete(:clave_hash)

          record = ::Infrastructure::Orm::UsuarioRecord.new(attrs)
          record[:clave_hash] = clave_hash if clave_hash
          record.save!

          ::Infrastructure::Mappers::UsuarioMapper.to_domain(record)
        end

        def update_existing(usuario)
          record = ::Infrastructure::Orm::UsuarioRecord.find(usuario.id)
          attrs = ::Infrastructure::Mappers::UsuarioMapper.to_record_attrs(usuario)

          # Remove clave_hash from attrs and set it directly via []=
          # to bypass has_secure_password's setter override
          clave_hash = attrs.delete(:clave_hash)
          record.assign_attributes(attrs.except(:id, :created_at))
          record[:clave_hash] = clave_hash if clave_hash
          record.save!

          ::Infrastructure::Mappers::UsuarioMapper.to_domain(record.reload)
        end
      end
    end
  end
end
