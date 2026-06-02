# frozen_string_literal: true

module Domain
  module Entities
    class EmpleadoParada
      attr_reader :id, :empleado_id, :parada_id, :activo, :estado, :created_at, :updated_at

      def initialize(id:, empleado_id:, parada_id:, activo: true, estado: "activo", created_at: nil, updated_at: nil)
        @id = id
        @empleado_id = empleado_id
        @parada_id = parada_id
        @activo = activo
        @estado = estado
        @created_at = created_at
        @updated_at = updated_at
      end

      def activo?
        @activo == true
      end
    end
  end
end
