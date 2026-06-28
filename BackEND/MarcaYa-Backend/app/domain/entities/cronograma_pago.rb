# app/domain/entities/cronograma_pago.rb

# frozen_string_literal: true

module Domain
  module Entities
    class CronogramaPago
      attr_reader :id, :empleado_id, :obra_id, :periodo,
                  :horas_trabajadas, :tarifa_hora, :monto_total,
                  :estado, :created_at, :updated_at

      def initialize(id:, empleado_id:, obra_id:, periodo:,
                     horas_trabajadas:, tarifa_hora:, monto_total:,
                     estado: "pendiente", created_at: nil, updated_at: nil)
        @id               = id
        @empleado_id      = empleado_id
        @obra_id          = obra_id
        @periodo          = periodo
        @horas_trabajadas = horas_trabajadas
        @tarifa_hora      = tarifa_hora
        @monto_total      = monto_total
        @estado           = estado
        @created_at       = created_at
        @updated_at       = updated_at
      end

      def validar!
        raise Domain::Errors::ValidacionError, "empleado_id es obligatorio" if @empleado_id.nil?
        raise Domain::Errors::ValidacionError, "obra_id es obligatorio"     if @obra_id.nil?
        raise Domain::Errors::ValidacionError, "periodo es obligatorio"     if @periodo.nil? || @periodo.strip.empty?
        raise Domain::Errors::ValidacionError, "tarifa_hora debe ser positiva" unless @tarifa_hora.to_f > 0
        raise Domain::Errors::ValidacionError, "horas_trabajadas no puede ser negativa" if @horas_trabajadas.to_f < 0
      end
    end
  end
end
