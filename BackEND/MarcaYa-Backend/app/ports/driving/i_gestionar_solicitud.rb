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

      # @param empleado_id [Integer] The employee ID
      # @param empresa_id [Integer] The empresa ID
      # @return [Domain::Entities::Solicitud]
      def self.crear(empleado_id:, empresa_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The solicitud ID
      # @param obra_id [Integer] The obra ID
      # @return [Domain::Entities::Solicitud]
      def self.aceptar(id:, obra_id:)
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
