# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class ListarParadas
        def initialize(parada_repo:, obra_repo:)
          @parada_repo = parada_repo
          @obra_repo = obra_repo
        end

        def ejecutar(obra_id:)
          @obra_repo.find_by_id!(obra_id)
          @parada_repo.listar_por_obra(obra_id)
        end
      end
    end
  end
end
