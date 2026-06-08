# frozen_string_literal: true

module Infrastructure
  module Services
    class ResendEmailService
      include Domain::Ports::INotificadorEmail

      def enviar_codigo(destino:, codigo:)
        PasswordRecoveryMailer.codigo_recuperacion(destino, codigo).deliver_now
      end
    end
  end
end
