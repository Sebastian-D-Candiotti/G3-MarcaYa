# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Obra repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IObraRepository
      # @param id [Integer] The obra ID
      # @return [Domain::Entities::Obra]
      # @raise [StandardError] if not found
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @return [Array<Domain::Entities::Obra>]
      def self.listar_activas
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empresa_id [Integer] The company ID
      # @return [Array<Domain::Entities::Obra>]
      def self.listar_por_empresa(empresa_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param obra [Domain::Entities::Obra] The obra to persist
      # @return [Domain::Entities::Obra]
      def self.guardar(obra)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param obra [Domain::Entities::Obra] The obra to delete
      # @return [Boolean]
      def self.eliminar(obra)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
