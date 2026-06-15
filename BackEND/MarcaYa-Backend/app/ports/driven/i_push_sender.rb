# frozen_string_literal: true

module Ports
  module Driven
    # Interface for sending push notifications via FCM.
    # All methods raise NotImplementedError — concrete implementations must override them.
    module IPushSender
      def self.enviar(notificacion, fcm_token)
        raise NotImplementedError, "#{name}##{__method__} must be implemented"
      end
    end
  end
end
