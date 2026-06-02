# frozen_string_literal: true

module Application
  module UseCases
    module Obras
      class ListarObras
        def initialize(obra_repo:)
          @obra_repo = obra_repo
        end

        def ejecutar
          @obra_repo.todos
        end
      end
    end
  end
end
