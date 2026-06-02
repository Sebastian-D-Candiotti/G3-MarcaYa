# frozen_string_literal: true

module Domain
  module Entities
    class Asignacion
      attr_reader :id, :empleado_id, :obra_id, :estado, :created_at, :updated_at

      def initialize(id:, empleado_id:, obra_id:, estado: "activo", created_at: nil, updated_at: nil)
        @id = id
        @empleado_id = empleado_id
        @obra_id = obra_id
        @estado = estado
        @created_at = created_at
        @updated_at = updated_at
      end
    end
  end
end
