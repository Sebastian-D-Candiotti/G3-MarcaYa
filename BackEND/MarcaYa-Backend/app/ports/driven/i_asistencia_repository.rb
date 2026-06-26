# frozen_string_literal: true

module Ports
  module Driven
    # Interface for RegistroAsistencia repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IAsistenciaRepository
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.buscar_entrada_activa(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.historial_por_empleado(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.ultimo_registro_por_empleado
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.ultimo_registro_por_parada(parada_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.buscar_entrada_hoy(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.guardar(registro)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
