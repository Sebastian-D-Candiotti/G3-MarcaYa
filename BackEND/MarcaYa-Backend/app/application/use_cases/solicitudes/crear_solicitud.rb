# frozen_string_literal: true

module Application
  module UseCases
    module Solicitudes
      class CrearSolicitud
        def initialize(solicitud_repo:, asignacion_repo: nil, obra_repo: nil)
          @solicitud_repo = solicitud_repo
          @asignacion_repo = asignacion_repo
          @obra_repo = obra_repo
        end

        def ejecutar(empleado_id:, empresa_id:)
          solicitudes_existentes = @solicitud_repo.listar_por_empleado(empleado_id)

          # Ya tiene una solicitud pendiente
          if solicitudes_existentes.any? { |s| s.pendiente? && s.empresa_id == empresa_id }
            raise Domain::Errors::ValidacionError,
                  "El empleado ya tiene una solicitud pendiente para esta empresa"
          end

          # Ya fue aceptado en esta empresa
          if solicitudes_existentes.any? { |s| s.aceptada? && s.empresa_id == empresa_id }
            raise Domain::Errors::ValidacionError,
                  "El empleado ya pertenece a esta empresa"
          end

          # Ya está asignado a una obra de esta empresa
          if @asignacion_repo && @obra_repo
            obras_empresa = @obra_repo.listar_por_empresa(empresa_id).map(&:id).to_set
            asignaciones = @asignacion_repo.listar_por_empleado(empleado_id)
            if asignaciones.any? { |a| obras_empresa.include?(a.obra_id) }
              raise Domain::Errors::ValidacionError,
                    "El empleado ya está asignado a una obra de esta empresa"
            end
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
