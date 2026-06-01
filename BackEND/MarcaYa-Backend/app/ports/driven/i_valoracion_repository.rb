# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Valoracion repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IValoracionRepository
      # @param empresa_id [Integer] The company ID
      # @return [Array<Domain::Entities::Valoracion>]
      def self.listar_por_empresa(empresa_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param valoracion [Domain::Entities::Valoracion] The valoracion to persist
      # @return [Domain::Entities::Valoracion]
      def self.guardar(valoracion)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
