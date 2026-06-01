# frozen_string_literal: true

module Ports
  module Driving
    # Interface for employee-related query use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarEmpleado
      # @param empleado_id [Integer] The employee ID
      # @return [Array<Domain::Entities::Obra>]
      def self.obtener_obras(empleado_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @return [Array<Domain::Entities::Empleado>]
      def self.listar_actuales
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
