# frozen_string_literal: true

module Ports
  module Driving
    # Interface for obra management use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarObra
      # @return [Array<Domain::Entities::Obra>]
      def self.listar
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The obra ID
      # @return [Domain::Entities::Obra]
      # @raise [Domain::Errors::ObraNoEncontradaError] if not found
      def self.obtener(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param params [Hash] Obra creation parameters
      # @return [Domain::Entities::Obra]
      def self.crear(params)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The obra ID
      # @param params [Hash] Updated attributes
      # @return [Domain::Entities::Obra]
      def self.actualizar(id:, params:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The obra ID
      # @return [Boolean]
      def self.eliminar(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
