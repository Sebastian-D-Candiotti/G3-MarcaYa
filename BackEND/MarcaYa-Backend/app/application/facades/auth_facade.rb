# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IAutenticarUsuario
    class AuthFacade
      def initialize(usuario_repo:, empleado_repo:, empresa_repo:,
                     bcrypt_service:, jwt_service:, notificador:,
                     verification_code_service:, verification_mailer:)
        @usuario_repo = usuario_repo
        @bcrypt_service = bcrypt_service
        @jwt_service = jwt_service
        @notificador = notificador
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

      def solicitar_codigo(correo:)
        @solicitar_codigo ||= UseCases::Auth::SolicitarCodigoRecuperacion.new(
          usuario_repo: @usuario_repo,
          notificador: @notificador
        )
        @solicitar_codigo.ejecutar(correo: correo)
      end

      def verificar_codigo(correo:, codigo:)
        @verificar_codigo ||= UseCases::Auth::VerificarCodigoRecuperacion.new(
          usuario_repo: @usuario_repo,
          jwt_service: @jwt_service
        )
        @verificar_codigo.ejecutar(correo: correo, codigo: codigo)
      end

      def restablecer_contrasena(verification_token:, nueva_clave:)
        @restablecer_contrasena ||= UseCases::Auth::RestablecerContrasena.new(
          usuario_repo: @usuario_repo,
          bcrypt_service: @bcrypt_service
        )
        @restablecer_contrasena.ejecutar(
          verification_token: verification_token,
          nueva_clave: nueva_clave
        )
      end
    end
  end
end
