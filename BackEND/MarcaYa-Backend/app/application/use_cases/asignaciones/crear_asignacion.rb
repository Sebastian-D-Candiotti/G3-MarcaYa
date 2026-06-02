# frozen_string_literal: true

module Application
  module UseCases
    module Asignaciones
      class CrearAsignacion
        def initialize(asignacion_repo:, obra_repo:)
          @asignacion_repo = asignacion_repo
          @obra_repo = obra_repo
        end

        def ejecutar(empleado_id:, obra_id:, empresa_id:)
          obra = @obra_repo.find_by_id!(obra_id)

          if obra.empresa_id != empresa_id
            raise Domain::Errors::ValidacionError,
                  "La obra no pertenece a la empresa de la solicitud"
          end

          asignacion = Domain::Entities::Asignacion.new(
            id: nil,
            empleado_id: empleado_id,
            obra_id: obra_id,
            estado: "activo"
          )

          @asignacion_repo.guardar(asignacion)
        end
      end
    end
  end
end
