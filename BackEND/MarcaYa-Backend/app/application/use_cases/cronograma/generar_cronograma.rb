#app/application/use_cases/cronograma/generar_cronograma.rb

# frozen_string_literal: true

module Application
  module UseCases
    module Cronograma
      class GenerarCronograma
        def initialize(asistencia_repo:, cronograma_repo:)
          @asistencia_repo = asistencia_repo
          @cronograma_repo = cronograma_repo
        end

        # empleado_id : Integer
        # obra_id     : Integer
        # periodo     : String  (ej: "2026-06", "semana-1-junio")
        # tarifa_hora : Float   (S/. por hora)
        def ejecutar(empleado_id:, obra_id:, periodo:, tarifa_hora:)
          # 1. Obtener todos los registros del empleado
          registros = @asistencia_repo.historial_por_empleado(empleado_id)

          # 2. Sumar horas SOLO de registros con valida_gps: true y tipo SALIDA
          #    (duracion_jornada está en minutos — se convierte a horas)
          horas_validas = registros
            .select { |r| r.valida_gps && r.salida? && !r.duracion_jornada.nil? }
            .sum    { |r| r.duracion_jornada.to_f / 60.0 }
            .round(2)

          # 3. Calcular monto total
          monto_total = (horas_validas * tarifa_hora.to_f).round(2)

          # 4. Construir entidad y validar
          cronograma = Domain::Entities::CronogramaPago.new(
            id:               nil,
            empleado_id:      empleado_id,
            obra_id:          obra_id,
            periodo:          periodo,
            horas_trabajadas: horas_validas,
            tarifa_hora:      tarifa_hora.to_f,
            monto_total:      monto_total,
            estado:           "pendiente"
          )
          cronograma.validar!

          # 5. Persistir en cronograma_de_pagos
          @cronograma_repo.guardar(cronograma)
        end
      end
    end
  end
end
