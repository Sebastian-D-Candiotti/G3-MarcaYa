# frozen_string_literal: true

module Application
  module UseCases
    module Usuarios
      class ObtenerUsuario
        def initialize(usuario_repo:)
          @usuario_repo = usuario_repo
        end

        def ejecutar(id:)
          @usuario_repo.find_by_id!(id)
        end
      end
    end
  end
end
