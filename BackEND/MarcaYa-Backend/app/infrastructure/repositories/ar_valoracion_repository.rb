# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IValoracionRepository
    class ArValoracionRepository
      class << self
        def listar_por_empresa(empresa_id)
          ::Infrastructure::Orm::ValoracionRecord.where(empresa_id: empresa_id).map { |r| ::Infrastructure::Mappers::ValoracionMapper.to_domain(r) }
        end

        def guardar(valoracion)
          attrs = ::Infrastructure::Mappers::ValoracionMapper.to_record_attrs(valoracion)

          if valoracion.id
            record = ::Infrastructure::Orm::ValoracionRecord.find(valoracion.id)
            record.update!(attrs.except(:id, :created_at))
            ::Infrastructure::Mappers::ValoracionMapper.to_domain(record.reload)
          else
            record = ::Infrastructure::Orm::ValoracionRecord.create!(attrs.except(:id))
            ::Infrastructure::Mappers::ValoracionMapper.to_domain(record)
          end
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Valoracion con id #{valoracion.id} no encontrada"
        end
      end
    end
  end
end
