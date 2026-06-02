# frozen_string_literal: true

module Ports
  module Driven
    # Interface for Parada repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IParadaRepository
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.listar_por_obra(obra_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.buscar_por_nombre_y_obra(nombre, obra_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.guardar(parada)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.eliminar(parada)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
