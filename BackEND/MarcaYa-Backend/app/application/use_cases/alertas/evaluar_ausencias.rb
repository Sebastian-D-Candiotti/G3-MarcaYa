# frozen_string_literal: true

module Application
  module UseCases
    module Alertas
      class EvaluarAusencias
        def initialize(alerta_repo:, obra_repo:, asistencia_repo:)
          @alerta_repo = alerta_repo
          @obra_repo = obra_repo
          @asistencia_repo = asistencia_repo
        end

        def ejecutar
          obras_con_asignaciones = @obra_repo.listar_activas_con_asignaciones
          evaluadas = 0
          creadas = 0
          resueltas = 0

          obras_con_asignaciones.each do |entry|
            obra = entry[:obra]
            asignaciones = entry[:asignaciones]

            # Skip if current time hasn't passed the tolerance window
            next unless tolerancia_excedida?(obra)

            asignaciones.each do |asignacion|
              empleado_id = asignacion.empleado_id
              tiene_entrada = @asistencia_repo.buscar_entrada_hoy(empleado_id)
              evaluadas += 1

              if tiene_entrada
                resueltas += 1 if resolver_si_pendiente(empleado_id, obra, Date.today)
              else
                creadas += 1 if crear_alerta(empleado_id, obra)
              end
            end
          end

          { evaluadas: evaluadas, creadas: creadas, resueltas: resueltas }
        end

        private

        def tolerancia_excedida?(obra)
          now = Time.now
          hora_inicio_today = Time.new(
            now.year, now.month, now.day,
            obra.hora_inicio.hour, obra.hora_inicio.min, 0
          )
          tiempo_tolerancia = hora_inicio_today + (obra.tolerancia_entrada_min * 60)
          now >= tiempo_tolerancia
        end

        def resolver_si_pendiente(empleado_id, obra, fecha)
          alerta = @alerta_repo.buscar_por_empleado_y_fecha(empleado_id, fecha)
          return false unless alerta&.pendiente?

          @alerta_repo.actualizar_estado(alerta.id, "resuelta")
          true
        end

        def crear_alerta(empleado_id, obra)
          fecha = Date.today
          existe = @alerta_repo.buscar_por_empleado_y_fecha(empleado_id, fecha)
          return false if existe

          alerta = Domain::Entities::AlertaAusencia.new(
            id: nil,
            empleado_id: empleado_id,
            obra_id: obra.id,
            empresa_id: obra.empresa_id,
            fecha: fecha,
            estado: "pendiente",
            evaluado_en: Time.now
          )
          @alerta_repo.guardar(alerta)
          true
        end
      end
    end
  end
end
