# frozen_string_literal: true

module Ports
  module Driving
    # Interface for solicitud management use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarSolicitud
      # @return [Array<Domain::Entities::Solicitud>]
      def self.listar
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param params [Hash] Solicitud creation parameters
      # @return [Domain::Entities::Solicitud]
      def self.crear(params)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The solicitud ID
      # @return [Domain::Entities::Solicitud]
      def self.aceptar(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The solicitud ID
      # @return [Domain::Entities::Solicitud]
      def self.rechazar(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
