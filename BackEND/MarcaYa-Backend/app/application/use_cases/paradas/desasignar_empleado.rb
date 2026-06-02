# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class DesasignarEmpleado
        def initialize(parada_repo:, empleado_parada_repo:)
          @parada_repo = parada_repo
          @empleado_parada_repo = empleado_parada_repo
        end

        def ejecutar(parada_id:, empleado_id:)
          @parada_repo.find_by_id!(parada_id)

          asignacion = @empleado_parada_repo.buscar_asignacion(empleado_id, parada_id)

          if asignacion && asignacion.activo?
            inactiva_asig = Domain::Entities::EmpleadoParada.new(
              id: asignacion.id,
              empleado_id: empleado_id,
              parada_id: parada_id,
              activo: false,
              estado: "inactivo",
              created_at: asignacion.created_at
            )
            @empleado_parada_repo.guardar(inactiva_asig)
          end
          true
        end
      end
    end
  end
end
