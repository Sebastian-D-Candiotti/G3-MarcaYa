# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class SolicitarCodigoRecuperacion
        def initialize(usuario_repo:, notificador:)
          @usuario_repo = usuario_repo
          @notificador = notificador
        end

        def ejecutar(correo:)
          usuario = @usuario_repo.find_by_correo(correo)

          if usuario
            codigo = SecureRandom.rand(100_000..999_999).to_s
            codigo_expira = 15.minutes.from_now

            usuario_actualizado = Domain::Entities::Usuario.new(
              id: usuario.id,
              correo: usuario.correo,
              clave_hash: usuario.clave_hash,
              rol: usuario.rol.valor,
              estado: usuario.estado,
              codigo_recuperacion: codigo,
              codigo_expira: codigo_expira,
              created_at: usuario.created_at,
              updated_at: usuario.updated_at
            )

            @usuario_repo.guardar(usuario_actualizado)
            @notificador.enviar_codigo(destino: correo, codigo: codigo)
          end

          { mensaje: "Código enviado si el correo existe" }
        end
      end
    end
  end
end
