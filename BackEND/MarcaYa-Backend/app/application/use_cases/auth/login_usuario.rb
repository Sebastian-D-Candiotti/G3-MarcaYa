# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class LoginUsuario
        BCRYPT_PREFIXES = %w[$2a$ $2b$ $2y$].freeze

        def initialize(usuario_repo:, bcrypt_service:, jwt_service:)
          @usuario_repo = usuario_repo
          @bcrypt_service = bcrypt_service
          @jwt_service = jwt_service
        end

        def ejecutar(correo:, clave:)
          usuario = @usuario_repo.find_by_correo(correo)
          raise Domain::Errors::UsuarioNoEncontradoError unless usuario

          unless @bcrypt_service.verificar?(clave, usuario.clave_hash)
            raise Domain::Errors::CredencialesInvalidasError
          end

          raise Domain::Errors::CuentaPendienteVerificacionError if usuario.pendiente_verificacion?
          raise Domain::Errors::UsuarioInactivoError unless usuario.activo?

          migrar_si_es_plano!(usuario, clave)

          token = @jwt_service.encode("user_id" => usuario.id, "rol" => usuario.rol.valor)

          { usuario: usuario, token: token }
        end

        private

        def migrar_si_es_plano!(usuario, clave)
          return if BCRYPT_PREFIXES.any? { |p| usuario.clave_hash.start_with?(p) }

          nueva_hash = @bcrypt_service.hash(clave)
          usuario_migrado = Domain::Entities::Usuario.new(
            id: usuario.id,
            correo: usuario.correo,
            clave_hash: nueva_hash,
            rol: usuario.rol.valor,
            estado: usuario.estado,
            codigo_recuperacion: usuario.codigo_recuperacion,
            codigo_expira: usuario.codigo_expira,
            estado_verificacion: usuario.estado_verificacion,
            codigo_verificacion_digest: usuario.codigo_verificacion_digest,
            codigo_verificacion_expira_en: usuario.codigo_verificacion_expira_en,
            verificado_en: usuario.verificado_en,
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )
          @usuario_repo.guardar(usuario_migrado)
        end
      end
    end
  end
end
