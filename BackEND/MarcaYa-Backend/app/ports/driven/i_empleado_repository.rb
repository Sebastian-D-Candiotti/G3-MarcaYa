# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Empleado repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IEmpleadoRepository
      # @param id [Integer] The employee ID
      # @return [Domain::Entities::Empleado]
      # @raise [StandardError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param usuario_id [Integer] The user ID
      # @return [Domain::Entities::Empleado, nil]
      def self.find_by_usuario_id(usuario_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @return [Array<Domain::Entities::Empleado>]
      def self.todos
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado [Domain::Entities::Empleado] The employee to persist
      # @return [Domain::Entities::Empleado]
      def self.guardar(empleado)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_ids [Array<Integer>]
      # @param estado [String] "activo" or "inactivo"
      # @return [Array<Domain::Entities::Empleado>]
      def self.por_ids_y_estado(empleado_ids, estado)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
