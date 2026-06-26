# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class RegistrarUsuario
        CAMPOS_OBLIGATORIOS = %i[correo clave rol nombre].freeze

        def initialize(usuario_repo:, empleado_repo:, empresa_repo:, bcrypt_service:, jwt_service:,
                       verification_code_service:, verification_mailer:,
                       reniec_service:)
          @usuario_repo = usuario_repo
          @empleado_repo = empleado_repo
          @empresa_repo = empresa_repo
          @bcrypt_service = bcrypt_service
          @jwt_service = jwt_service
          @verification_code_service = verification_code_service
          @verification_mailer = verification_mailer
          @reniec_service = reniec_service
        end

        def ejecutar(params)
          # Si es registro SUNAT, precargamos el nombre de la empresa antes de validar campos
          if params[:rol].to_s == "empresa" && (params[:registro_tipo].to_s == "sunat" || params[:codigo].present?)
            ruc = params[:ruc].to_s.strip
            empresa_sunat = Domain::Services::SunatService.buscar_por_ruc(ruc)
            if empresa_sunat
              params[:nombre] = empresa_sunat.razon_social
            end
          end

          validar_campos!(params)

          correo = params[:correo]
          clave = params[:clave]
          rol = params[:rol]

          if @usuario_repo.exists_by_correo?(correo)
            existing = @usuario_repo.find_by_correo(correo)
            if existing.pendiente_verificacion?
              return reenviar_para_pendiente(existing)
            end
            raise Domain::Errors::ValidacionError, "El correo ya está registrado"
          end

          if rol.to_s == "empresa"
            ruc = params[:ruc].to_s.strip
            registro_tipo = params[:registro_tipo].to_s.strip

            if registro_tipo == "sunat"
              codigo = params[:codigo].to_s.strip
              if ruc.empty? || codigo.empty?
                raise Domain::Errors::ValidacionError, "El RUC y el código de verificación son obligatorios para el registro SUNAT"
              end

              unless @empresa_repo.verificar_codigo_ruc?(ruc, codigo)
                raise Domain::Errors::ValidacionError, "Código de verificación inválido o expirado"
              end
            else
              # Registro manual
              validar_correo_corporativo!(correo)

              if ruc.length != 11
                raise Domain::Errors::ValidacionError, "El RUC debe tener exactamente 11 dígitos"
              end

              unless ruc.start_with?("10", "20")
                raise Domain::Errors::ValidacionError, "El RUC debe comenzar con 10 o 20"
              end

              if @empresa_repo.exists_by_ruc?(ruc)
                raise Domain::Errors::ValidacionError, "El RUC ya se encuentra registrado"
              end
            end
          elsif rol.to_s == "empleado"
            validar_empleado_con_reniec!(params)
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

          # Si es flujo manual de empresa, generamos y enviamos el código OTP
          if rol.to_s == "empresa" && params[:registro_tipo].to_s == "manual"
            codigo_otp = rand(100000..999999).to_s
            expira_at = 15.minutes.from_now
            verificacion = Infrastructure::Orm::VerificacionRucRecord.find_or_initialize_by(ruc: params[:ruc].to_s.strip)
            verificacion.update!(codigo: codigo_otp, expira_at: expira_at)

            mensaje_otp = "\n========================================\n" \
                          "[MAILER] Código de verificación manual enviado a: #{correo}\n" \
                          "RUC: #{params[:ruc]} | Empresa: #{params[:nombre]}\n" \
                          "CÓDIGO DE VERIFICACIÓN: #{codigo_otp}\n" \
                          "========================================\n"
            puts mensaje_otp
            Rails.logger.info(mensaje_otp) if defined?(Rails) && Rails.logger

            begin
              UsuarioMailer.correo_verificacion_ruc(correo, codigo_otp, params[:nombre]).deliver_now if defined?(UsuarioMailer)
            rescue StandardError => e
              Rails.logger.error("Error al enviar correo de verificacion via ActionMailer: #{e.message}") if defined?(Rails) && Rails.logger
            end
          end

          { usuario: usuario, requiere_verificacion: true }
        end

        private

        def validar_correo_corporativo!(correo)
          dominio = correo.to_s.split("@").last.to_s.strip.downcase
          dominios_publicos = %w[gmail.com hotmail.com yahoo.com outlook.com live.com icloud.com mail.com yahoo.es outlook.es]
          if dominios_publicos.include?(dominio)
            raise Domain::Errors::ValidacionError, "El correo electrónico debe ser un correo corporativo (no se permiten dominios públicos como Gmail, Hotmail, etc.)"
          end
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
            empleado_existente = @empleado_repo.find_by_dni(dni)
            usuario_dni = @usuario_repo.find_by_id!(empleado_existente.usuario_id)
            if usuario_dni.pendiente_verificacion?
              raise Domain::Errors::ValidacionError,
                    "Este DNI ya tiene un registro pendiente. Usá el correo con el que te registraste originalmente."
            end
            raise Domain::Errors::ValidacionError, "El DNI ya está registrado"
          end
          datos_reniec = @reniec_service.consultar(dni)
          if datos_reniec.nil?
            raise Domain::Errors::ValidacionError, "No se encontraron datos en RENIEC para este DNI"
          end
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
            is_otp_verificado = (params[:registro_tipo].to_s == "sunat" || params[:codigo].present?)
            @empresa_repo.guardar(
              Domain::Entities::Empresa.new(
                id: nil, usuario_id: usuario.id,
                nombre_empresa: params[:nombre],
                ruc: params[:ruc] || "",
                descripcion: params[:descripcion],
                direccion: params[:direccion], telefono: params[:telefono],
                foto_url: params[:foto_url], estado: "PENDIENTE",
                otp_verificado: is_otp_verificado
              )
            )
          end
        end

        def reenviar_para_pendiente(usuario_existente)
          codigo = @verification_code_service.generate

          usuario_actualizado = Domain::Entities::Usuario.new(
            id: usuario_existente.id,
            correo: usuario_existente.correo,
            clave_hash: usuario_existente.clave_hash,
            rol: usuario_existente.rol,
            estado: usuario_existente.estado,
            estado_verificacion: usuario_existente.estado_verificacion,
            codigo_verificacion_digest: @verification_code_service.digest(codigo),
            codigo_verificacion_expira_en: @verification_code_service.expires_at
          )
          @usuario_repo.guardar(usuario_actualizado)
          enviar_codigo!(correo: usuario_existente.correo, codigo: codigo)

          { usuario: usuario_existente, requiere_verificacion: true, ya_registrado: true }
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
