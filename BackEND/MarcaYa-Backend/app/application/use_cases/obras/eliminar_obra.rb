# frozen_string_literal: true

module Application
  module UseCases
    module Obras
      class EliminarObra
        def initialize(obra_repo:)
          @obra_repo = obra_repo
        end

        def ejecutar(id:)
          obra = @obra_repo.find_by_id!(id)
          @obra_repo.eliminar(obra)
        rescue StandardError
          raise Domain::Errors::ObraNoEncontradaError
        end
      end
    end
  end
end
