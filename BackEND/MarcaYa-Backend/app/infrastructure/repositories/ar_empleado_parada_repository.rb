# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IEmpleadoParadaRepository
    class ArEmpleadoParadaRepository
      def find_by_id!(id)
        record = ::Infrastructure::Orm::EmpleadoParadaRecord.find(id)
        ::Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::ValidacionError, "Asignación de parada con id #{id} no encontrada"
      end

      def buscar_asignacion(empleado_id, parada_id)
        record = ::Infrastructure::Orm::EmpleadoParadaRecord.find_by(empleado_id: empleado_id, parada_id: parada_id)
        return nil unless record

        ::Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(record)
      end

      def listar_activos_por_parada(parada_id)
        ::Infrastructure::Orm::EmpleadoParadaRecord.where(parada_id: parada_id, activo: true).map do |record|
          ::Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(record)
        end
      end

      def guardar(empleado_parada)
        attrs = ::Infrastructure::Mappers::EmpleadoParadaMapper.to_record_attrs(empleado_parada)

        if empleado_parada.id
          record = ::Infrastructure::Orm::EmpleadoParadaRecord.find(empleado_parada.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::EmpleadoParadaRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(record)
        end
      end
    end
  end
end
