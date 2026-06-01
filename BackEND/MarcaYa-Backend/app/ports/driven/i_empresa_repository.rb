# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Empresa repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IEmpresaRepository
      # @param id [Integer] The company ID
      # @return [Domain::Entities::Empresa]
      # @raise [StandardError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param usuario_id [Integer] The user ID
      # @return [Domain::Entities::Empresa, nil]
      def self.find_by_usuario_id(usuario_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empresa [Domain::Entities::Empresa] The company to persist
      # @return [Domain::Entities::Empresa]
      def self.guardar(empresa)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
