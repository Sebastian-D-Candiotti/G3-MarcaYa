#app/infrastructure/mappers/cronograma_pago_mapper.rb
# frozen_string_literal: true

module Infrastructure
  module Mappers
    class CronogramaPagoMapper
      def self.to_domain(record)
        Domain::Entities::CronogramaPago.new(
          id:               record.id,
          empleado_id:      record.empleado_id,
          obra_id:          record.obra_id,
          periodo:          record.periodo,
          horas_trabajadas: record.horas_trabajadas.to_f,
          tarifa_hora:      record.tarifa_hora.to_f,
          monto_total:      record.monto_total.to_f,
          estado:           record.estado,
          created_at:       record.created_at,
          updated_at:       record.updated_at
        )
      end

      def self.to_record_attrs(entity)
        {
          empleado_id:      entity.empleado_id,
          obra_id:          entity.obra_id,
          periodo:          entity.periodo,
          horas_trabajadas: entity.horas_trabajadas,
          tarifa_hora:      entity.tarifa_hora,
          monto_total:      entity.monto_total,
          estado:           entity.estado
        }
      end
    end
  end
end
