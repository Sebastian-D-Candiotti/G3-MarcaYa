# frozen_string_literal: true

module Application
  module UseCases
    module Asistencias
      class TiempoReal
        def initialize(asistencia_repo:)
          @asistencia_repo = asistencia_repo
        end

        def ejecutar(parada_id: nil)
          if parada_id
            @asistencia_repo.ultimo_registro_por_parada(parada_id)
          else
            @asistencia_repo.ultimo_registro_por_empleado
          end
        end
      end
    end
  end
end
