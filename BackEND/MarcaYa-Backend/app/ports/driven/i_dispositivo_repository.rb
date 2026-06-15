# frozen_string_literal: true

module Ports
  module Driven
    # Interface for device (FCM token) repository operations.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IDispositivoRepository
      def self.activos_por_empleado(empleado_id)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end

      def self.crear_o_actualizar(user_id:, fcm_token:, platform:)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
