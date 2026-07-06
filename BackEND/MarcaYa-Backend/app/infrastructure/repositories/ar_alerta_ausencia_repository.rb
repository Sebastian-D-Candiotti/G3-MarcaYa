# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IAlertaAusenciaRepository
    class ArAlertaAusenciaRepository
      def guardar(alerta)
        attrs = ::Infrastructure::Mappers::AlertaAusenciaMapper.to_record_attrs(alerta)

        if alerta.id
          record = ::Infrastructure::Orm::AlertaAusenciaRecord.find(alerta.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::AlertaAusenciaRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(record)
        end
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::AlertaAusenciaNoEncontradaError,
              "Alerta de ausencia con id #{alerta.id} no encontrada"
      end

      def listar_por_empresa(empresa_id, estado: "pendiente")
        ::Infrastructure::Orm::AlertaAusenciaRecord
          .where(empresa_id: empresa_id, estado: estado)
          .map { |record| ::Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(record) }
      end

      def listar_por_empresa_con_detalles(empresa_id, estado: "pendiente")
        ::Infrastructure::Orm::AlertaAusenciaRecord
          .where(empresa_id: empresa_id, estado: estado)
          .includes(:empleado, :obra)
          .map do |record|
            {
              id: record.id,
              empleado_id: record.empleado_id,
              empleado_nombre: record.empleado.nombre,
              empleado_apellido: record.empleado.apellido,
              obra_id: record.obra_id,
              obra_nombre: record.obra.nombre,
              empresa_id: record.empresa_id,
              fecha: record.fecha,
              estado: record.estado,
              evaluado_en: record.evaluado_en
            }
          end
      end

      def buscar_por_empleado_y_fecha(empleado_id, fecha)
        record = ::Infrastructure::Orm::AlertaAusenciaRecord
          .find_by(empleado_id: empleado_id, fecha: fecha)
        return nil unless record

        ::Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(record)
      end

      def find_by_id!(id)
        record = ::Infrastructure::Orm::AlertaAusenciaRecord.find(id)
        ::Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::AlertaAusenciaNoEncontradaError,
              "Alerta de ausencia con id #{id} no encontrada"
      end

      def actualizar_estado(id, nuevo_estado)
        record = ::Infrastructure::Orm::AlertaAusenciaRecord.find(id)
        record.update!(estado: nuevo_estado)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::AlertaAusenciaNoEncontradaError,
              "Alerta de ausencia con id #{id} no encontrada"
      end
    end
  end
end
