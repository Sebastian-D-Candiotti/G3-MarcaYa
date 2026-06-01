# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::ISolicitudRepository
    class ArSolicitudRepository
      class << self
        def find_by_id!(id)
          record = ::Infrastructure::Orm::SolicitudRecord.find(id)
          ::Infrastructure::Mappers::SolicitudMapper.to_domain(record)
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Solicitud con id #{id} no encontrada"
        end

        def listar_por_empleado(empleado_id)
          ::Infrastructure::Orm::SolicitudRecord.where(empleado_id: empleado_id).map { |r| ::Infrastructure::Mappers::SolicitudMapper.to_domain(r) }
        end

        def listar_por_obra(obra_id)
          ::Infrastructure::Orm::SolicitudRecord.where(obra_id: obra_id).map { |r| ::Infrastructure::Mappers::SolicitudMapper.to_domain(r) }
        end

        def listar_pendientes
          ::Infrastructure::Orm::SolicitudRecord.where(estado: "pendiente").map { |r| ::Infrastructure::Mappers::SolicitudMapper.to_domain(r) }
        end

        def guardar(solicitud)
          attrs = ::Infrastructure::Mappers::SolicitudMapper.to_record_attrs(solicitud)

          if solicitud.id
            record = ::Infrastructure::Orm::SolicitudRecord.find(solicitud.id)
            record.update!(attrs.except(:id, :created_at))
            ::Infrastructure::Mappers::SolicitudMapper.to_domain(record.reload)
          else
            record = ::Infrastructure::Orm::SolicitudRecord.create!(attrs.except(:id))
            ::Infrastructure::Mappers::SolicitudMapper.to_domain(record)
          end
        rescue ActiveRecord::RecordNotFound
          raise StandardError, "Solicitud con id #{solicitud.id} no encontrada"
        end
      end
    end
  end
end
