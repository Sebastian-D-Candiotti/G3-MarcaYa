# frozen_string_literal: true

module Application
  module UseCases
    module Usuarios
      class ActualizarUsuario
        def initialize(usuario_repo:)
          @usuario_repo = usuario_repo
        end

        def ejecutar(id:, params:)
          usuario_existente = @usuario_repo.find_by_id!(id)

          usuario_actualizado = Domain::Entities::Usuario.new(
            id: usuario_existente.id,
            correo: params[:correo] || usuario_existente.correo,
            clave_hash: usuario_existente.clave_hash,
            rol: params[:rol] || usuario_existente.rol.valor,
            estado: params.key?(:estado) ? params[:estado] : usuario_existente.estado,
            codigo_recuperacion: usuario_existente.codigo_recuperacion,
            codigo_expira: usuario_existente.codigo_expira,
            created_at: usuario_existente.created_at,
            updated_at: usuario_existente.updated_at
          )

          @usuario_repo.guardar(usuario_actualizado)
        end
      end
    end
  end
end
