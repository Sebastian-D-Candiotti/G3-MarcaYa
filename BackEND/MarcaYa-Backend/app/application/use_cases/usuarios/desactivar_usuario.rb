# frozen_string_literal: true

module Application
  module UseCases
    module Usuarios
      class DesactivarUsuario
        def initialize(usuario_repo:)
          @usuario_repo = usuario_repo
        end

        def ejecutar(id:)
          usuario = @usuario_repo.find_by_id!(id)

          usuario_desactivado = Domain::Entities::Usuario.new(
            id: usuario.id,
            correo: usuario.correo,
            clave_hash: usuario.clave_hash,
            rol: usuario.rol.valor,
            estado: false,
            codigo_recuperacion: usuario.codigo_recuperacion,
            codigo_expira: usuario.codigo_expira,
            created_at: usuario.created_at,
            updated_at: usuario.updated_at
          )

          @usuario_repo.guardar(usuario_desactivado)
        end
      end
    end
  end
end
