# frozen_string_literal: true

module Ports
  module Driven
    # Interface for EmpleadoParada repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IEmpleadoParadaRepository
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.buscar_asignacion(empleado_id, parada_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.listar_activos_por_parada(parada_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.guardar(empleado_parada)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.empleado_ids_por_paradas(parada_ids)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
