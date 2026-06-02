# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IParadaRepository
    class ArParadaRepository
      def find_by_id!(id)
        record = ::Infrastructure::Orm::ParadaRecord.find(id)
        ::Infrastructure::Mappers::ParadaMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::ParadaNoEncontradaError, "Parada con id #{id} no encontrada"
      end

      def listar_por_obra(obra_id)
        ::Infrastructure::Orm::ParadaRecord.where(obra_id: obra_id).map do |record|
          ::Infrastructure::Mappers::ParadaMapper.to_domain(record)
        end
      end

      def buscar_por_nombre_y_obra(nombre, obra_id)
        record = ::Infrastructure::Orm::ParadaRecord.find_by(nombre: nombre, obra_id: obra_id)
        return nil unless record

        ::Infrastructure::Mappers::ParadaMapper.to_domain(record)
      end

      def guardar(parada)
        attrs = ::Infrastructure::Mappers::ParadaMapper.to_record_attrs(parada)

        if parada.id
          record = ::Infrastructure::Orm::ParadaRecord.find(parada.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::ParadaMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::ParadaRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::ParadaMapper.to_domain(record)
        end
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::ParadaNoEncontradaError, "Parada con id #{parada.id} no encontrada"
      end

      def eliminar(parada)
        ::Infrastructure::Orm::ParadaRecord.destroy(parada.id)
        true
      end
    end
  end
end
