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

        def ejecutar(correo:, clave:, device_id: nil)
          usuario = @usuario_repo.find_by_correo(correo)
          raise Domain::Errors::UsuarioNoEncontradoError unless usuario

          unless @bcrypt_service.verificar?(clave, usuario.clave_hash)
            raise Domain::Errors::CredencialesInvalidasError
          end

          raise Domain::Errors::UsuarioInactivoError unless usuario.activo?

          migrar_si_es_plano!(usuario, clave)

          if usuario.es_empleado?
            empleado_repo = Rails.configuration.di.repos[:empleado]
            empleado = empleado_repo.find_by_usuario_id(usuario.id)

            if empleado
              if device_id.to_s.strip.empty?
                raise Domain::Errors::CredencialesInvalidasError, "No se recibió identificador del dispositivo"
              end

              if empleado.device_id.nil? || empleado.device_id.to_s.strip.empty?
                empleado_actualizado = Domain::Entities::Empleado.new(
                  id: empleado.id,
                  usuario_id: empleado.usuario_id,
                  nombre: empleado.nombre,
                  apellido: empleado.apellido,
                  dni: empleado.dni,
                  telefono: empleado.telefono,
                  descripcion: empleado.descripcion,
                  foto_url: empleado.foto_url,
                  estado: empleado.estado,
                  device_id: device_id,
                  created_at: empleado.created_at,
                  updated_at: empleado.updated_at
                )

                empleado_repo.guardar(empleado_actualizado)
              elsif empleado.device_id != device_id
                raise Domain::Errors::CredencialesInvalidasError, "No puedes acceder desde otro dispositivo"
              end
            end
          end

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
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )
          @usuario_repo.guardar(usuario_migrado)
        end
      end
    end
  end
end
