# frozen_string_literal: true

module Application
  module UseCases
    module Asistencias
      class HistorialEmpleado
        def initialize(asistencia_repo:)
          @asistencia_repo = asistencia_repo
        end

        def ejecutar(empleado_id:)
          @asistencia_repo.historial_por_empleado(empleado_id)
        end
      end
    end
  end
end
