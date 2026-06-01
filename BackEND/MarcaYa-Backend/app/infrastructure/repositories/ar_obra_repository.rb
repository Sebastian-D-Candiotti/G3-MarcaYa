# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IObraRepository
    class ArObraRepository
      class << self
        def find_by_id!(id)
          record = ::Infrastructure::Orm::ObraRecord.find(id)
          ::Infrastructure::Mappers::ObraMapper.to_domain(record)
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Obra con id #{id} no encontrada"
        end

        def listar_activas
          ::Infrastructure::Orm::ObraRecord.where(estado: "activa").map { |r| ::Infrastructure::Mappers::ObraMapper.to_domain(r) }
        end

        def listar_por_empresa(empresa_id)
          ::Infrastructure::Orm::ObraRecord.where(empresa_id: empresa_id).map { |r| ::Infrastructure::Mappers::ObraMapper.to_domain(r) }
        end

        def guardar(obra)
          attrs = ::Infrastructure::Mappers::ObraMapper.to_record_attrs(obra)

          if obra.id
            record = ::Infrastructure::Orm::ObraRecord.find(obra.id)
            record.update!(attrs.except(:id, :created_at))
            ::Infrastructure::Mappers::ObraMapper.to_domain(record.reload)
          else
            record = ::Infrastructure::Orm::ObraRecord.create!(attrs.except(:id))
            ::Infrastructure::Mappers::ObraMapper.to_domain(record)
          end
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Obra con id #{obra.id} no encontrada"
        end

        def eliminar(obra)
          ::Infrastructure::Orm::ObraRecord.destroy(obra.id)
          true
        end
      end
    end
  end
end
