# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class ReenviarCodigoVerificacion
        def initialize(usuario_repo:, verification_code_service:, verification_mailer:)
          @usuario_repo = usuario_repo
          @verification_code_service = verification_code_service
          @verification_mailer = verification_mailer
        end

        def ejecutar(correo:)
          raise Domain::Errors::ValidacionError, "Correo es obligatorio" if correo.to_s.strip.empty?

          usuario = @usuario_repo.find_by_correo(correo)
          raise Domain::Errors::UsuarioNoEncontradoError unless usuario
          raise Domain::Errors::CodigoVerificacionUsadoError if usuario.verificado?

          codigo = @verification_code_service.generate
          usuario_actualizado = actualizar_codigo(usuario, codigo)
          enviar_codigo!(correo: usuario_actualizado.correo, codigo: codigo)

          usuario_actualizado
        end

        private

        def actualizar_codigo(usuario, codigo)
          @usuario_repo.guardar(
            Domain::Entities::Usuario.new(
              id: usuario.id,
              correo: usuario.correo,
              clave_hash: usuario.clave_hash,
              rol: usuario.rol.valor,
              estado: false,
              codigo_recuperacion: usuario.codigo_recuperacion,
              codigo_expira: usuario.codigo_expira,
              estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_PENDIENTE,
              codigo_verificacion_digest: @verification_code_service.digest(codigo),
              codigo_verificacion_expira_en: @verification_code_service.expires_at,
              verificado_en: nil,
              created_at: usuario.created_at,
              updated_at: usuario.updated_at
            )
          )
        end

        def enviar_codigo!(correo:, codigo:)
          @verification_mailer
            .with(correo: correo, codigo: codigo, minutos_validez: 10)
            .codigo_verificacion
            .deliver_now
        rescue StandardError => e
          raise Domain::Errors::CorreoVerificacionNoEnviadoError,
                "No se pudo enviar el correo de verificacion: #{e.message}"
        end
      end
    end
  end
end
