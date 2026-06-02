# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class RegistrarUsuario
        CAMPOS_OBLIGATORIOS = %i[correo clave rol nombre].freeze

        def initialize(usuario_repo:, empleado_repo:, empresa_repo:, bcrypt_service:, jwt_service:)
          @usuario_repo = usuario_repo
          @empleado_repo = empleado_repo
          @empresa_repo = empresa_repo
          @bcrypt_service = bcrypt_service
          @jwt_service = jwt_service
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

          usuario = @usuario_repo.guardar(
            Domain::Entities::Usuario.new(
              id: nil, correo: correo, clave_hash: clave_hash,
              rol: rol, estado: true
            )
          )

          crear_perfil!(usuario, params)

          token = @jwt_service.encode("user_id" => usuario.id, "rol" => usuario.rol.valor)

          { usuario: usuario, token: token }
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
      end
    end
  end
end
