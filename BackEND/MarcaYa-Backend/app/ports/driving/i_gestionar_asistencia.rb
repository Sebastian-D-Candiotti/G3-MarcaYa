# frozen_string_literal: true

module Ports
  module Driving
    # Interface for asistencia management use cases.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IGestionarAsistencia
      # @param empleado_id [Integer] The empleado ID
      # @param parada_id [Integer] The parada ID
      # @param latitud [Float] Latitude of the mark
      # @param longitud [Float] Longitude of the mark
      # @return [Domain::Entities::RegistroAsistencia]
      def self.marcar_entrada(empleado_id:, parada_id:, latitud:, longitud:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The empleado ID
      # @param parada_id [Integer] The parada ID
      # @param latitud [Float] Latitude of the mark
      # @param longitud [Float] Longitude of the mark
      # @return [Domain::Entities::RegistroAsistencia]
      def self.marcar_salida(empleado_id:, parada_id:, latitud:, longitud:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The empleado ID
      # @return [Array<Domain::Entities::RegistroAsistencia>]
      def self.historial_personal(empleado_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param empleado_id [Integer] The empleado ID
      # @return [Array<Domain::Entities::RegistroAsistencia>]
      def self.historial_empleado(empleado_id:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      # @param parada_id [Integer, nil] Optional parada ID to filter by
      # @return [Array<Domain::Entities::RegistroAsistencia>]
      def self.tiempo_real(parada_id: nil)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
