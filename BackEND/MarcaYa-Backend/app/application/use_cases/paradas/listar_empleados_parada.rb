# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class ListarEmpleadosParada
        def initialize(parada_repo:, empleado_parada_repo:, empleado_repo:)
          @parada_repo = parada_repo
          @empleado_parada_repo = empleado_parada_repo
          @empleado_repo = empleado_repo
        end

        def ejecutar(parada_id:)
          @parada_repo.find_by_id!(parada_id)

          # Traer solo las relaciones con activo: true
          asignaciones_activas = @empleado_parada_repo.listar_activos_por_parada(parada_id)

          # Obtener datos de los empleados correspondientes
          asignaciones_activas.map do |asig|
            @empleado_repo.find_by_id!(asig.empleado_id)
          end
        end
      end
    end
  end
end
