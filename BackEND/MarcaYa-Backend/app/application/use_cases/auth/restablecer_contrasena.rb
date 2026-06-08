# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class RestablecerContrasena
        def initialize(usuario_repo:, bcrypt_service:)
          @usuario_repo = usuario_repo
          @bcrypt_service = bcrypt_service
        end

        def ejecutar(verification_token:, nueva_clave:)
          payload = decode_verification_token!(verification_token)

          raise Domain::Errors::TokenRecuperacionInvalidoError unless payload["purpose"] == "password_reset"

          usuario = @usuario_repo.find_by_id!(payload["user_id"])

          raise Domain::Errors::ValidacionError, "La contraseña debe tener al menos 8 caracteres." if nueva_clave.length < 8

          nueva_hash = @bcrypt_service.hash(nueva_clave)

          usuario_actualizado = Domain::Entities::Usuario.new(
            id: usuario.id,
            correo: usuario.correo,
            clave_hash: nueva_hash,
            rol: usuario.rol.valor,
            estado: usuario.estado,
            codigo_recuperacion: nil,
            codigo_expira: nil,
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )

          @usuario_repo.guardar(usuario_actualizado)

          { mensaje: "Contraseña actualizada correctamente" }
        end

        private

        def decode_verification_token!(verification_token)
          Jwt.decode(verification_token)
        rescue JWT::DecodeError
          raise Domain::Errors::TokenRecuperacionInvalidoError
        end
      end
    end
  end
end
