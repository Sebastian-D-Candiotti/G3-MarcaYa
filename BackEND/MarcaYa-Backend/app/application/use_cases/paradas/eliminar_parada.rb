# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class EliminarParada
        def initialize(parada_repo:)
          @parada_repo = parada_repo
        end

        def ejecutar(id:)
          parada = @parada_repo.find_by_id!(id)
          @parada_repo.eliminar(parada)
          true
        end
      end
    end
  end
end
