# frozen_string_literal: true

module Application
  module UseCases
    module Alertas
      class ResolverAlerta
        def initialize(alerta_repo:)
          @alerta_repo = alerta_repo
        end

        def ejecutar(id:, estado: "resuelta")
          @alerta_repo.actualizar_estado(id, estado)
        end
      end
    end
  end
end
