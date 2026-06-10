# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class RegistrarUsuario
        CAMPOS_OBLIGATORIOS = %i[correo clave rol nombre].freeze

        def initialize(usuario_repo:, empleado_repo:, empresa_repo:, bcrypt_service:, jwt_service:,
                       verification_code_service:, verification_mailer:)
          @usuario_repo = usuario_repo
          @empleado_repo = empleado_repo
          @empresa_repo = empresa_repo
          @bcrypt_service = bcrypt_service
          @jwt_service = jwt_service
          @verification_code_service = verification_code_service
          @verification_mailer = verification_mailer
        end

        def ejecutar(params)
          validar_campos!(params)

          correo = params[:correo]
          clave = params[:clave]
          rol = params[:rol]

          if @usuario_repo.exists_by_correo?(correo)
            raise Domain::Errors::ValidacionError, "El correo ya está registrado"
          end

          clave_hash = @bcrypt_service.hash(clave)
          codigo = @verification_code_service.generate

          usuario = @usuario_repo.guardar(
            Domain::Entities::Usuario.new(
              id: nil, correo: correo, clave_hash: clave_hash,
              rol: rol,
              estado: false,
              estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_PENDIENTE,
              codigo_verificacion_digest: @verification_code_service.digest(codigo),
              codigo_verificacion_expira_en: @verification_code_service.expires_at
            )
          )

          crear_perfil!(usuario, params)
          enviar_codigo!(correo: usuario.correo, codigo: codigo)

          { usuario: usuario, requiere_verificacion: true }
        end

        private

        def validar_campos!(params)
          faltantes = CAMPOS_OBLIGATORIOS.select do |campo|
            params[campo].nil? || params[campo].to_s.strip.empty?
          end
          return if faltantes.empty?

          raise Domain::Errors::ValidacionError,
                "Campos obligatorios faltantes: #{faltantes.join(', ')}"
        end

        def crear_perfil!(usuario, params)
          if usuario.es_empleado?
            @empleado_repo.guardar(
              Domain::Entities::Empleado.new(
                id: nil, usuario_id: usuario.id,
                nombre: params[:nombre],
                apellido: params[:apellido] || "",
                dni: params[:dni], telefono: params[:telefono],
                descripcion: params[:descripcion], foto_url: params[:foto_url],
                estado: "activo"
              )
            )
          elsif usuario.es_empresa?
            @empresa_repo.guardar(
              Domain::Entities::Empresa.new(
                id: nil, usuario_id: usuario.id,
                nombre_empresa: params[:nombre],
                ruc: params[:ruc] || "",
                descripcion: params[:descripcion],
                direccion: params[:direccion], telefono: params[:telefono],
                foto_url: params[:foto_url], estado: "activo"
              )
            )
          end
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
