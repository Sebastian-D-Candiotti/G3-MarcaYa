# frozen_string_literal: true

module Application
  module UseCases
    module Obras
      class ObtenerObra
        def initialize(obra_repo:)
          @obra_repo = obra_repo
        end

        def ejecutar(id:)
          @obra_repo.find_by_id!(id)
        rescue StandardError
          raise Domain::Errors::ObraNoEncontradaError
        end
      end
    end
  end
end
