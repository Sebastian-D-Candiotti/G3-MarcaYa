# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class RegistrarUsuario
        CAMPOS_OBLIGATORIOS = %i[correo clave rol nombre].freeze

        def initialize(usuario_repo:, empleado_repo:, empresa_repo:, bcrypt_service:, jwt_service:, reniec_service:)
          @usuario_repo = usuario_repo
          @empleado_repo = empleado_repo
          @empresa_repo = empresa_repo
          @bcrypt_service = bcrypt_service
          @jwt_service = jwt_service
          @reniec_service = reniec_service
        end

        def ejecutar(params)
          validar_campos!(params)

          correo = params[:correo]
          clave = params[:clave]
          rol = params[:rol]

          if @usuario_repo.exists_by_correo?(correo)
            raise Domain::Errors::ValidacionError, "El correo ya está registrado"
          end

          if rol.to_s == "empleado"
            validar_empleado_con_reniec!(params)
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

        def validar_empleado_con_reniec!(params)
          dni = params[:dni].to_s.strip
          unless dni.match?(/\A\d{8}\z/)
            raise Domain::Errors::ValidacionError, "El DNI debe tener exactamente 8 números"
          end
          if @empleado_repo.exists_by_dni?(dni)
            raise Domain::Errors::ValidacionError, "El DNI ya está registrado"
          end
          datos_reniec = @reniec_service.consultar(dni)
          if datos_reniec.nil?
            raise Domain::Errors::ValidacionError, "No se encontraron datos en RENIEC para este DNI"
          end
          params[:nombre] = datos_reniec[:nombres]
          params[:apellido] = "#{datos_reniec[:apellido_paterno]} #{datos_reniec[:apellido_materno]}".strip
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
