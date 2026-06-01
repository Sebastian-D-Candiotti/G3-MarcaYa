# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Usuario repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IUsuarioRepository
      # @param id [Integer] The user ID
      # @return [Domain::Entities::Usuario]
      # @raise [Domain::Errors::UsuarioNoEncontradoError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param correo [String] The email address
      # @return [Domain::Entities::Usuario, nil]
      def self.find_by_correo(correo)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param usuario [Domain::Entities::Usuario] The user to persist
      # @return [Domain::Entities::Usuario]
      def self.guardar(usuario)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param correo [String] The email address
      # @return [Boolean]
      def self.exists_by_correo?(correo)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
