# frozen_string_literal: true

module Ports
  module Driving
    # Interface for authentication use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IAutenticarUsuario
      # @param correo [String] The user email
      # @param clave [String] The user password
      # @return [Hash] Session/token data
      # @raise [Domain::Errors::CredencialesInvalidasError] if credentials are wrong
      # @raise [Domain::Errors::UsuarioInactivoError] if user is inactive
      def self.login(correo:, clave:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param params [Hash] Registration parameters
      # @return [Domain::Entities::Usuario]
      # @raise [Domain::Errors::ValidacionError] if validation fails
      def self.registro(params)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param usuario_id [Integer] The user ID
      # @return [Boolean]
      def self.logout(usuario_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
