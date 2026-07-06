# frozen_string_literal: true

module Ports
  module Driven
    # Interface for AlertaAusencia repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IAlertaAusenciaRepository
      # @param alerta [Domain::Entities::AlertaAusencia] The alert to persist
      # @return [Domain::Entities::AlertaAusencia]
      def self.guardar(alerta)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empresa_id [Integer] The company ID
      # @param estado [String] Filter by estado (default: "pendiente")
      # @return [Array<Domain::Entities::AlertaAusencia>]
      def self.listar_por_empresa(empresa_id, estado: "pendiente")
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # Returns enriched alert data including empleado/obra names (for API responses)
      # @param empresa_id [Integer] The company ID
      # @param estado [String] Filter by estado (default: "pendiente")
      # @return [Array<Hash>] Hashes with id, empleado_id, empleado_nombre, empleado_apellido, obra_id, obra_nombre, empresa_id, fecha, estado, evaluado_en
      def self.listar_por_empresa_con_detalles(empresa_id, estado: "pendiente")
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The employee ID
      # @param fecha [Date] The date to search
      # @return [Domain::Entities::AlertaAusencia, nil]
      def self.buscar_por_empleado_y_fecha(empleado_id, fecha)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The alert ID
      # @return [Domain::Entities::AlertaAusencia]
      # @raise [Domain::Errors::AlertaAusenciaNoEncontradaError]
      def self.find_by_id!(id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param id [Integer] The alert ID
      # @param nuevo_estado [String] The new estado value
      def self.actualizar_estado(id, nuevo_estado)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
