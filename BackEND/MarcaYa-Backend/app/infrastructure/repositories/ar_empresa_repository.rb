# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IEmpresaRepository
    class ArEmpresaRepository
      class << self
        def find_by_id!(id)
          record = ::Infrastructure::Orm::EmpresaRecord.find(id)
          ::Infrastructure::Mappers::EmpresaMapper.to_domain(record)
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Empresa con id #{id} no encontrada"
        end

        def find_by_usuario_id(usuario_id)
          record = ::Infrastructure::Orm::EmpresaRecord.find_by(usuario_id: usuario_id)
          return nil unless record

          ::Infrastructure::Mappers::EmpresaMapper.to_domain(record)
        end

        def guardar(empresa)
          attrs = ::Infrastructure::Mappers::EmpresaMapper.to_record_attrs(empresa)

          if empresa.id
            record = ::Infrastructure::Orm::EmpresaRecord.find(empresa.id)
            record.update!(attrs.except(:id, :created_at))
            ::Infrastructure::Mappers::EmpresaMapper.to_domain(record.reload)
          else
            record = ::Infrastructure::Orm::EmpresaRecord.create!(attrs.except(:id))
            ::Infrastructure::Mappers::EmpresaMapper.to_domain(record)
          end
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Empresa con id #{empresa.id} no encontrada"
        end
      end
    end
  end
end
