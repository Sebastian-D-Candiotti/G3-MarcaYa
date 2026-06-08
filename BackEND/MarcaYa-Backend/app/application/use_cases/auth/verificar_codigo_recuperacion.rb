# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class VerificarCodigoRecuperacion
        def initialize(usuario_repo:, jwt_service:)
          @usuario_repo = usuario_repo
          @jwt_service = jwt_service
        end

        def ejecutar(correo:, codigo:)
          usuario = @usuario_repo.find_by_correo(correo)
          raise Domain::Errors::CodigoInvalidoError unless usuario
          raise Domain::Errors::CodigoInvalidoError if usuario.codigo_recuperacion.nil? || usuario.codigo_recuperacion != codigo
          raise Domain::Errors::CodigoExpiradoError if usuario.codigo_expira.nil? || Time.current > usuario.codigo_expira

          # Consume the code (single-use)
          usuario_actualizado = Domain::Entities::Usuario.new(
            id: usuario.id,
            correo: usuario.correo,
            clave_hash: usuario.clave_hash,
            rol: usuario.rol.valor,
            estado: usuario.estado,
            codigo_recuperacion: nil,
            codigo_expira: nil,
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )

          @usuario_repo.guardar(usuario_actualizado)

          verification_token = Jwt.encode(
            { "user_id" => usuario.id, "purpose" => "password_reset" },
            5.minutes.from_now
          )

          { verification_token: verification_token }
        end
      end
    end
  end
end
