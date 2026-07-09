# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IAsistenciaRepository
    class ArAsistenciaRepository
      def find_by_id!(id)
        record = ::Infrastructure::Orm::AsistenciaRecord.find(id)
        ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record)
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::AsistenciaNoEncontradaError, "Registro de asistencia con id #{id} no encontrado"
      end

      def historial_por_empleado(empleado_id)
        ::Infrastructure::Orm::AsistenciaRecord
          .where(empleado_id: empleado_id)
          .order(fecha_hora: :desc)
          .map { |record| ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record) }
      end

      def buscar_entrada_activa(empleado_id)
        record = ::Infrastructure::Orm::AsistenciaRecord
          .where(empleado_id: empleado_id, tipo_marcacion: "ENTRADA")
          .where(duracion_jornada: nil)
          .order(fecha_hora: :desc)
          .first
        return nil unless record

        ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record)
      end

      def find_by_cliente_marcacion_id(cliente_marcacion_id)
        return nil if cliente_marcacion_id.to_s.strip.empty?

        record = ::Infrastructure::Orm::AsistenciaRecord.find_by(
          cliente_marcacion_id: cliente_marcacion_id
        )
        return nil unless record

        ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record)
      end

      def ultimo_registro_por_empleado
        # Returns the last registro per employee — uses a subquery to get max id per empleado_id.
        max_ids = ::Infrastructure::Orm::AsistenciaRecord
          .group(:empleado_id)
          .select("MAX(id) AS max_id")

        ::Infrastructure::Orm::AsistenciaRecord
          .where(id: max_ids.select(:max_id))
          .map { |record| ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record) }
      end

      def ultimo_registro_por_parada(parada_id)
        ::Infrastructure::Orm::AsistenciaRecord
          .where(parada_id: parada_id)
          .order(fecha_hora: :desc)
          .map { |record| ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record) }
      end

      def buscar_entrada_hoy(empleado_id)
        ::Infrastructure::Orm::AsistenciaRecord
          .where(empleado_id: empleado_id, tipo_marcacion: "ENTRADA")
          .where(fecha_hora: Time.current.all_day)
          .exists?
      end

      def por_paradas_y_periodo(parada_ids, inicio, fin)
        ::Infrastructure::Orm::AsistenciaRecord
          .where(parada_id: parada_ids, fecha_hora: inicio..fin)
          .map { |record| ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record) }
      end

      def por_paradas_y_periodo_y_tipo(parada_ids, inicio, fin, tipo)
        ::Infrastructure::Orm::AsistenciaRecord
          .where(parada_id: parada_ids, fecha_hora: inicio..fin, tipo_marcacion: tipo)
          .map { |record| ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record) }
      end

      def guardar(registro)
        attrs = ::Infrastructure::Mappers::AsistenciaMapper.to_record_attrs(registro)

        if registro.id
          record = ::Infrastructure::Orm::AsistenciaRecord.find(registro.id)
          record.update!(attrs.except(:id, :created_at))
          ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record.reload)
        else
          record = ::Infrastructure::Orm::AsistenciaRecord.create!(attrs.except(:id))
          ::Infrastructure::Mappers::AsistenciaMapper.to_domain(record)
        end
      rescue ActiveRecord::RecordNotFound
        raise Domain::Errors::AsistenciaNoEncontradaError, "Registro de asistencia con id #{registro.id} no encontrado"
      end
    end
  end
end
