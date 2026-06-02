# frozen_string_literal: true

module Application
  module UseCases
    module Usuarios
      class ListarUsuarios
        def initialize(usuario_repo:)
          @usuario_repo = usuario_repo
        end

        def ejecutar
          @usuario_repo.todos
        end
      end
    end
  end
end
