# frozen_string_literal: true

module Domain
  module Entities
    class AlertaAusencia
      attr_reader :id, :empleado_id, :obra_id, :empresa_id, :fecha,
                  :estado, :evaluado_en, :created_at, :updated_at

      ESTADOS = %w[pendiente resuelta desestimada].freeze

      def initialize(id:, empleado_id:, obra_id:, empresa_id:, fecha:,
                     estado: "pendiente", evaluado_en: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @empleado_id = empleado_id
        @obra_id = obra_id
        @empresa_id = empresa_id
        @fecha = fecha
        @estado = estado
        @evaluado_en = evaluado_en
        @created_at = created_at
        @updated_at = updated_at
      end

      def pendiente?
        @estado == "pendiente"
      end

      def resuelta?
        @estado == "resuelta"
      end

      def desestimada?
        @estado == "desestimada"
      end

      def activa?
        pendiente?
      end
    end
  end
end
