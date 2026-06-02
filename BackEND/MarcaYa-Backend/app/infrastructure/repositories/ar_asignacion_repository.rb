# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IAsignacionRepository
    class ArAsignacionRepository
      def find_by_id!(id)
        record = ::Infrastructure::Orm::AsignacionRecord.find(id)
        ::Infrastructure::Mappers::AsignacionMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise StandardError, "Asignacion con id #{id} no encontrada"
      end

      def listar_por_empleado(empleado_id)
        ::Infrastructure::Orm::AsignacionRecord.where(empleado_id: empleado_id).map do |record|
          ::Infrastructure::Mappers::AsignacionMapper.to_domain(record)
        end
      end

      def guardar(asignacion)
        attrs = ::Infrastructure::Mappers::AsignacionMapper.to_record_attrs(asignacion)

        if asignacion.id
          record = ::Infrastructure::Orm::AsignacionRecord.find(asignacion.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::AsignacionMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::AsignacionRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::AsignacionMapper.to_domain(record)
        end
      rescue ActiveRecord::RecordNotFound
        raise StandardError, "Asignacion con id #{asignacion.id} no encontrada"
      end
    end
  end
end
