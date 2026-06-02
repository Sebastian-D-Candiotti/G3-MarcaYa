# frozen_string_literal: true

module Application
  module UseCases
    module Empleados
      class ObtenerObrasEmpleado
        def initialize(empleado_repo:, asignacion_repo:, obra_repo:)
          @empleado_repo = empleado_repo
          @asignacion_repo = asignacion_repo
          @obra_repo = obra_repo
        end

        def ejecutar(empleado_id:)
          @empleado_repo.find_by_id!(empleado_id)

          asignaciones_activas = @asignacion_repo.listar_por_empleado(empleado_id)
                                                .select { |a| a.estado == "activo" }

          asignaciones_activas.map do |a|
            @obra_repo.find_by_id!(a.obra_id)
          end
        end
      end
    end
  end
end
