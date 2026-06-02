# frozen_string_literal: true

module Application
  module UseCases
    module Solicitudes
      class ListarSolicitudes
        def initialize(solicitud_repo:)
          @solicitud_repo = solicitud_repo
        end

        def ejecutar
          @solicitud_repo.listar_pendientes
        end
      end
    end
  end
end
