# frozen_string_literal: true

module Domain
  module Ports
    module INotificadorEmail
      def enviar_codigo(destino:, codigo:)
        raise NotImplementedError
      end
    end
  end
end
