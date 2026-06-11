# frozen_string_literal: true

module Infrastructure
  module Services
    class ResendEmailService
      include Domain::Ports::InotificadorEmail

      def enviar_codigo(destino:, codigo:)
        PasswordRecoveryMailer.codigo_recuperacion(destino, codigo).deliver_now
      rescue StandardError => e
        Rails.logger.warn "⚠️ [ResendEmailService] Error al enviar correo a #{destino}: #{e.message}"
        Rails.logger.warn "🔑 CÓDIGO DE RECUPERACIÓN GENERADO: #{codigo}"

        # En desarrollo/test, no queremos que el límite del sandbox de Resend rompa el flujo.
        puts "\n" + "="*80
        puts "⚠️ WARNING: No se pudo enviar el correo de recuperación a #{destino}."
        puts "Causa: #{e.message}"
        puts "🔑 CÓDIGO DE RECUPERACIÓN PARA #{destino}: #{codigo}"
        puts "="*80 + "\n"

        raise e unless Rails.env.development? || Rails.env.test?
      end
    end
  end
end
