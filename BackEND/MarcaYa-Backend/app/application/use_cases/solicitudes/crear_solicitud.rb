# frozen_string_literal: true

module Application
  module UseCases
    module Solicitudes
      class CrearSolicitud
        def initialize(solicitud_repo:)
          @solicitud_repo = solicitud_repo
        end

        def ejecutar(empleado_id:, empresa_id:)
          solicitudes_existentes = @solicitud_repo.listar_por_empleado(empleado_id)

          if solicitudes_existentes.any? { |s| s.pendiente? && s.empresa_id == empresa_id }
            raise Domain::Errors::ValidacionError,
                  "El empleado ya tiene una solicitud pendiente para esta empresa"
          end

          solicitud = Domain::Entities::Solicitud.new(
            id: nil,
            empleado_id: empleado_id,
            empresa_id: empresa_id,
            estado: "pendiente"
          )

          @solicitud_repo.guardar(solicitud)
        end
      end
    end
  end
end
