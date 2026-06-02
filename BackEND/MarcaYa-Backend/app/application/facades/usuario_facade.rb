# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarUsuario
    class UsuarioFacade
      def initialize(usuario_repo:)
        @obtener_usuario = UseCases::Usuarios::ObtenerUsuario.new(usuario_repo: usuario_repo)
        @listar_usuarios = UseCases::Usuarios::ListarUsuarios.new(usuario_repo: usuario_repo)
        @actualizar_usuario = UseCases::Usuarios::ActualizarUsuario.new(usuario_repo: usuario_repo)
        @desactivar_usuario = UseCases::Usuarios::DesactivarUsuario.new(usuario_repo: usuario_repo)
      end

      def obtener(id:)
        @obtener_usuario.ejecutar(id: id)
      end

      def listar
        @listar_usuarios.ejecutar
      end

      def actualizar(id:, params:)
        @actualizar_usuario.ejecutar(id: id, params: params)
      end

      def desactivar(id:)
        @desactivar_usuario.ejecutar(id: id)
      end
    end
  end
end
