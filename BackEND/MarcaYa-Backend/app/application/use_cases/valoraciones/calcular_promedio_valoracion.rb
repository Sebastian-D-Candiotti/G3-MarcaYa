# frozen_string_literal: true

module Application
  module UseCases
    module Valoraciones
      class CalcularPromedioValoracion
        def initialize(valoracion_repo:)
          @valoracion_repo = valoracion_repo
        end

        def ejecutar(empresa_id:)
          valoraciones = @valoracion_repo.listar_por_empresa(empresa_id)
          Domain::Services::ValoracionPromedioService.calcular(valoraciones)
        end
      end
    end
  end
end
