# frozen_string_literal: true

module Infrastructure
  module Repositories
    class ArCronogramaPagoRepository
      def guardar(cronograma)
        attrs = ::Infrastructure::Mappers::CronogramaPagoMapper.to_record_attrs(cronograma)

        if cronograma.id
          record = ::Infrastructure::Orm::CronogramaPagoRecord.find(cronograma.id)
          record.update!(attrs)
          ::Infrastructure::Mappers::CronogramaPagoMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::CronogramaPagoRecord.create!(attrs)
          ::Infrastructure::Mappers::CronogramaPagoMapper.to_domain(record)
        end
      end

      def listar_por_empleado(empleado_id)
        ::Infrastructure::Orm::CronogramaPagoRecord
          .where(empleado_id: empleado_id)
          .order(created_at: :desc)
          .map { |r| ::Infrastructure::Mappers::CronogramaPagoMapper.to_domain(r) }
      end

      def listar_por_obra(obra_id)
        ::Infrastructure::Orm::CronogramaPagoRecord
          .where(obra_id: obra_id)
          .order(created_at: :desc)
          .map { |r| ::Infrastructure::Mappers::CronogramaPagoMapper.to_domain(r) }
      end
    end
  end
end
