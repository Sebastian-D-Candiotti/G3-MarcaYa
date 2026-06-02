# frozen_string_literal: true

module Application
  module UseCases
    module Valoraciones
      class ListarValoracionesEmpresa
        def initialize(valoracion_repo:)
          @valoracion_repo = valoracion_repo
        end

        def ejecutar(empresa_id:)
          @valoracion_repo.listar_por_empresa(empresa_id)
        end
      end
    end
  end
end
