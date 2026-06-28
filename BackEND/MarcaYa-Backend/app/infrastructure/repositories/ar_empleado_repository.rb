#BackEND/app/infrastructure/repositories/ar_empleado_repository.rb
# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IEmpleadoRepository
    class ArEmpleadoRepository
      def find_by_id!(id)
        record = ::Infrastructure::Orm::EmpleadoRecord.find(id)
        ::Infrastructure::Mappers::EmpleadoMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise StandardError, "Empleado con id #{id} no encontrado"
      end

      def find_by_usuario_id(usuario_id)
        record = ::Infrastructure::Orm::EmpleadoRecord.find_by(usuario_id: usuario_id)
        return nil unless record

        ::Infrastructure::Mappers::EmpleadoMapper.to_domain(record)
      end

      def exists_by_dni?(dni)
        ::Infrastructure::Orm::EmpleadoRecord.exists?(dni: dni)
      end

      def todos
        ::Infrastructure::Orm::EmpleadoRecord.all.map { |r| ::Infrastructure::Mappers::EmpleadoMapper.to_domain(r) }
      end

      def guardar(empleado)
        attrs = ::Infrastructure::Mappers::EmpleadoMapper.to_record_attrs(empleado)

        if empleado.id
          record = ::Infrastructure::Orm::EmpleadoRecord.find(empleado.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::EmpleadoMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::EmpleadoRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::EmpleadoMapper.to_domain(record)
        end
      rescue ActiveRecord::RecordNotFound
        raise StandardError, "Empleado con id #{empleado.id} no encontrado"
      end
    end
  end
end
