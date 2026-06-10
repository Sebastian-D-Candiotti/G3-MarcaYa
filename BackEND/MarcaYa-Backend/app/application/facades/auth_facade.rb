# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IAutenticarUsuario
    class AuthFacade
      def initialize(usuario_repo:, empleado_repo:, empresa_repo:,
                     bcrypt_service:, jwt_service:, verification_code_service:,
                     verification_mailer:)
        @login_usuario = UseCases::Auth::LoginUsuario.new(
          usuario_repo: usuario_repo,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service
        )
        @registrar_usuario = UseCases::Auth::RegistrarUsuario.new(
          usuario_repo: usuario_repo,
          empleado_repo: empleado_repo,
          empresa_repo: empresa_repo,
          bcrypt_service: bcrypt_service,
          jwt_service: jwt_service,
          verification_code_service: verification_code_service,
          verification_mailer: verification_mailer
        )
        @verificar_cuenta = UseCases::Auth::VerificarCuenta.new(
          usuario_repo: usuario_repo,
          verification_code_service: verification_code_service
        )
        @reenviar_codigo_verificacion = UseCases::Auth::ReenviarCodigoVerificacion.new(
          usuario_repo: usuario_repo,
          verification_code_service: verification_code_service,
          verification_mailer: verification_mailer
        )
        @cerrar_sesion = UseCases::Auth::CerrarSesion.new
      end

      def login(correo:, clave:)
        @login_usuario.ejecutar(correo: correo, clave: clave)
      end

      def registro(params)
        @registrar_usuario.ejecutar(params)
      end

      def verificar_cuenta(correo:, codigo:)
        @verificar_cuenta.ejecutar(correo: correo, codigo: codigo)
      end

      def reenviar_codigo_verificacion(correo:)
        @reenviar_codigo_verificacion.ejecutar(correo: correo)
      end

      def logout(usuario_id:)
        @cerrar_sesion.ejecutar(usuario_id: usuario_id)
      end
    end
  end
end
