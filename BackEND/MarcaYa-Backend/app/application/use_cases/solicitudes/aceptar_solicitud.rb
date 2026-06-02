# frozen_string_literal: true

module Application
  module UseCases
    module Solicitudes
      class AceptarSolicitud
        def initialize(solicitud_repo:)
          @solicitud_repo = solicitud_repo
        end

        def ejecutar(id:)
          solicitud = @solicitud_repo.find_by_id!(id)
          solicitud.aceptar!
          @solicitud_repo.guardar(solicitud)
        end
      end
    end
  end
end
