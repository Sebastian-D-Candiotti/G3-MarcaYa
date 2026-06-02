# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Asignacion repository operations.
    module IAsignacionRepository
      # @param id [Integer] The asignacion ID
      # @return [Domain::Entities::Asignacion]
      # @raise [StandardError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The employee ID
      # @return [Array<Domain::Entities::Asignacion>]
      def self.listar_por_empleado(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param asignacion [Domain::Entities::Asignacion] The asignacion to persist
      # @return [Domain::Entities::Asignacion]
      def self.guardar(asignacion)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
