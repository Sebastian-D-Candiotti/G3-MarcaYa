# frozen_string_literal: true

module Application
  module UseCases
    module Alertas
      class ObtenerAlertasAusencia
        def initialize(alerta_repo:)
          @alerta_repo = alerta_repo
        end

        def ejecutar(empresa_id:)
          @alerta_repo.listar_por_empresa_con_detalles(empresa_id, estado: "pendiente")
        end
      end
    end
  end
end
