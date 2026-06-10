# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class VerificarCuenta
        def initialize(usuario_repo:, verification_code_service:)
          @usuario_repo = usuario_repo
          @verification_code_service = verification_code_service
        end

        def ejecutar(correo:, codigo:)
          validar_parametros!(correo: correo, codigo: codigo)

          usuario = @usuario_repo.find_by_correo(correo)
          raise Domain::Errors::UsuarioNoEncontradoError unless usuario
          raise Domain::Errors::CodigoVerificacionUsadoError if usuario.verificado?
          raise Domain::Errors::CodigoVerificacionVencidoError if codigo_vencido?(usuario)

          unless @verification_code_service.matches?(codigo, usuario.codigo_verificacion_digest)
            raise Domain::Errors::CodigoVerificacionInvalidoError
          end

          activar_usuario(usuario)
        end

        private

        def validar_parametros!(correo:, codigo:)
          if correo.to_s.strip.empty? || codigo.to_s.strip.empty?
            raise Domain::Errors::ValidacionError, "Correo y codigo son obligatorios"
          end

          return if codigo.to_s.match?(/\A\d{6}\z/)

          raise Domain::Errors::ValidacionError, "El codigo debe tener 6 digitos"
        end

        def codigo_vencido?(usuario)
          usuario.codigo_verificacion_expira_en.nil? ||
            usuario.codigo_verificacion_expira_en <= current_time
        end

        def activar_usuario(usuario)
          usuario_activo = Domain::Entities::Usuario.new(
            id: usuario.id,
            correo: usuario.correo,
            clave_hash: usuario.clave_hash,
            rol: usuario.rol.valor,
            estado: true,
            codigo_recuperacion: usuario.codigo_recuperacion,
            codigo_expira: usuario.codigo_expira,
            estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_ACTIVO,
            codigo_verificacion_digest: nil,
            codigo_verificacion_expira_en: nil,
            verificado_en: current_time,
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )

          @usuario_repo.guardar(usuario_activo)
        end

        def current_time
          Time.respond_to?(:current) ? Time.current : Time.now
        end
      end
    end
  end
end
