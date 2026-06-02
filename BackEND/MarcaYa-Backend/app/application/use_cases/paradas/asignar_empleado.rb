# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class AsignarEmpleado
        def initialize(parada_repo:, empleado_repo:, empleado_parada_repo:, asignacion_repo:)
          @parada_repo = parada_repo
          @empleado_repo = empleado_repo
          @empleado_parada_repo = empleado_parada_repo
          @asignacion_repo = asignacion_repo
        end

        def ejecutar(parada_id:, empleado_id:)
          parada = @parada_repo.find_by_id!(parada_id)
          @empleado_repo.find_by_id!(empleado_id)

          # RA2: El empleado MUST pertenecer a la misma obra de la parada
          asignaciones_obra = @asignacion_repo.listar_por_empleado(empleado_id)
          pertenece_a_obra = asignaciones_obra.any? { |a| a.obra_id == parada.obra_id && a.estado == "activo" }

          unless pertenece_a_obra
            raise Domain::Errors::ValidacionError, "El empleado no pertenece a la misma obra que la parada"
          end

          # Buscar asignación previa a la parada
          asignacion_existente = @empleado_parada_repo.buscar_asignacion(empleado_id, parada_id)

          if asignacion_existente
            if asignacion_existente.activo?
              raise Domain::Errors::ValidacionError, "El empleado ya está asignado de forma activa a esa parada"
            else
              # Reactivar asignación lógica
              nueva_asig = Domain::Entities::EmpleadoParada.new(
                id: asignacion_existente.id,
                empleado_id: empleado_id,
                parada_id: parada_id,
                activo: true,
                estado: "activo",
                created_at: asignacion_existente.created_at
              )
              @empleado_parada_repo.guardar(nueva_asig)
            end
          else
            # Crear nueva asociación activa
            nueva_asig = Domain::Entities::EmpleadoParada.new(
              id: nil,
              empleado_id: empleado_id,
              parada_id: parada_id,
              activo: true,
              estado: "activo"
            )
            @empleado_parada_repo.guardar(nueva_asig)
          end
        end
      end
    end
  end
end
