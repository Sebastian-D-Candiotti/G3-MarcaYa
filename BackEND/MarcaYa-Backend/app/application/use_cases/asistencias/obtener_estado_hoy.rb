# frozen_string_literal: true

module Application
  module UseCases
    module Asistencias
      class ObtenerEstadoHoy
        def initialize(asistencia_repo:)
          @asistencia_repo = asistencia_repo
        end

        def ejecutar(empleado_id:)
          marcado_hoy = @asistencia_repo.buscar_entrada_hoy(empleado_id)
          { marcado_hoy: marcado_hoy }
        end
      end
    end
  end
end
