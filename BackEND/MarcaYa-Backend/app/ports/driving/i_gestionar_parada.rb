# frozen_string_literal: true

module Ports
  module Driving
    # Interface for parada management use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarParada
      # @param obra_id [Integer] The obra ID
      # @return [Array<Domain::Entities::Parada>]
      def self.listar_por_obra(obra_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The parada ID
      # @return [Domain::Entities::Parada]
      def self.obtener(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param obra_id [Integer] The obra ID
      # @param params [Hash] Parada attributes
      # @return [Domain::Entities::Parada]
      def self.crear(obra_id:, params:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The parada ID
      # @param params [Hash] Updated attributes
      # @return [Domain::Entities::Parada]
      def self.actualizar(id:, params:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The parada ID
      # @return [true]
      def self.eliminar(id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param parada_id [Integer] The parada ID
      # @param empleado_id [Integer] The empleado ID
      # @return [Domain::Entities::EmpleadoParada]
      def self.asignar_empleado(parada_id:, empleado_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param parada_id [Integer] The parada ID
      # @param empleado_id [Integer] The empleado ID
      # @return [true]
      def self.desasignar_empleado(parada_id:, empleado_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param parada_id [Integer] The parada ID
      # @return [Array<Domain::Entities::Empleado>]
      def self.listar_empleados(parada_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
