# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Solicitud repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module ISolicitudRepository
      # @param id [Integer] The solicitud ID
      # @return [Domain::Entities::Solicitud]
      # @raise [StandardError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The employee ID
      # @return [Array<Domain::Entities::Solicitud>]
      def self.listar_por_empleado(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param obra_id [Integer] The obra ID
      # @return [Array<Domain::Entities::Solicitud>]
      def self.listar_por_obra(obra_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @return [Array<Domain::Entities::Solicitud>]
      def self.listar_pendientes
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param solicitud [Domain::Entities::Solicitud] The solicitud to persist
      # @return [Domain::Entities::Solicitud]
      def self.guardar(solicitud)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
