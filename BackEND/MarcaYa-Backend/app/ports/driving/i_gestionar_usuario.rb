# frozen_string_literal: true

module Ports
  module Driving
    # Interface for user management use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarUsuario
      # @param id [Integer] The user ID
      # @return [Domain::Entities::Usuario]
      # @raise [Domain::Errors::UsuarioNoEncontradoError] if not found
      def self.obtener(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @return [Array<Domain::Entities::Usuario>]
      def self.listar
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The user ID
      # @param params [Hash] Updated attributes
      # @return [Domain::Entities::Usuario]
      def self.actualizar(id:, params:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The user ID
      # @return [Boolean]
      def self.desactivar(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
