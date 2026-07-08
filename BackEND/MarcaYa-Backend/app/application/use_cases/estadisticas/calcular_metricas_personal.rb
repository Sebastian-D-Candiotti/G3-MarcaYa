# frozen_string_literal: true

module Application
  module UseCases
    module Estadisticas
      class CalcularMetricasPersonal
        def initialize(obra:, periodo:)
          @obra = obra
          @periodo = periodo || Date.today.strftime("%Y-%m")
        end

        def call
          inicio_mes = Date.strptime(@periodo, "%Y-%m").beginning_of_month
          fin_mes = inicio_mes.end_of_month.end_of_day

          paradas = ::Infrastructure::Orm::ParadaRecord.where(obra_id: @obra.id)
          parada_ids = paradas.pluck(:id)

          asistencias = ::Infrastructure::Orm::AsistenciaRecord
                          .where(parada_id: parada_ids)
                          .where(fecha_hora: inicio_mes..fin_mes)

          entradas = asistencias.where(tipo_marcacion: "entrada")
          salidas = asistencias.where(tipo_marcacion: "salida")

          empleado_ids = ::Infrastructure::Orm::EmpleadoParadaRecord
                           .where(parada_id: parada_ids)
                           .distinct
                           .pluck(:empleado_id)

          empleados = ::Infrastructure::Orm::EmpleadoRecord
                        .where(id: empleado_ids, estado: "activo")

          horas_totales = salidas.sum(:duracion_jornada).to_f / 60.0
          dias_trabajados = entradas.pluck(:empleado_id, :fecha_hora)
                                    .map { |empleado_id, fecha| [empleado_id, fecha.to_date] }
                                    .uniq
                                    .count

          tardanzas_total = contar_tardanzas(entradas)

          fake_gps_intentos = asistencias
                                .where("valida_gps = ? OR observaciones ILIKE ?", false, "%Fake GPS%")
                                .count

          puntualidad = entradas.count.zero? ? 100 : (((entradas.count - tardanzas_total).to_f / entradas.count) * 100).round(2)

          {
            tipo: "obra",
            obra_id: @obra.id,
            obra_nombre: @obra.nombre,
            empresa_id: @obra.empresa_id,
            periodo: @periodo,
            horas_promedio: dias_trabajados.zero? ? 0 : (horas_totales / dias_trabajados).round(2),
            horas_totales: horas_totales.round(2),
            puntualidad_porcentaje: puntualidad,
            empleados_activos: empleados.count,
            dias_trabajados: dias_trabajados,
            tardanzas_total: tardanzas_total,
            faltas_total: contar_faltas(empleados, entradas, inicio_mes, fin_mes),
            fake_gps_intentos: fake_gps_intentos,
            empleados_con_irregularidades: empleados_con_irregularidades(entradas, asistencias),
            datos_por_empleado: datos_por_empleado(empleados, asistencias, entradas, inicio_mes, fin_mes)
          }
        end

        private

        def dias_laborables(inicio_mes, fin_mes)
          inicio = inicio_mes.to_date
          fin = [fin_mes.to_date, Date.today].min

          (inicio..fin).select do |fecha|
            fecha.wday.between?(1, 6)
          end
        end

        def contar_faltas(empleados, entradas, inicio_mes, fin_mes)
          dias = dias_laborables(inicio_mes, fin_mes)

          empleados.sum do |empleado|
            entradas_empleado = entradas.where(empleado_id: empleado.id)

            fechas_con_entrada = entradas_empleado
                                  .pluck(:fecha_hora)
                                  .map(&:to_date)
                                  .uniq

            dias.count do |dia|
              !fechas_con_entrada.include?(dia)
            end
          end
        end

        def contar_faltas_empleado(empleado, entradas, inicio_mes, fin_mes)
          dias = dias_laborables(inicio_mes, fin_mes)

          fechas_con_entrada = entradas
                                .where(empleado_id: empleado.id)
                                .pluck(:fecha_hora)
                                .map(&:to_date)
                                .uniq

          dias.count do |dia|
            !fechas_con_entrada.include?(dia)
          end
        end

        def contar_tardanzas(entradas)
          entradas.select do |entrada|
            tarde?(entrada)
          end.count
        end

        def tarde?(entrada)
          return false unless @obra.hora_inicio

          hora = @obra.hora_inicio
          fecha = entrada.fecha_hora

          hora_limite = Time.zone.local(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.min,
            hora.sec
          ) + (@obra.tolerancia_entrada_min || 0).minutes

          entrada.fecha_hora > hora_limite
        end

        def empleados_con_irregularidades(entradas, asistencias)
          empleados_tarde = entradas.select { |entrada| tarde?(entrada) }.map(&:empleado_id)

          empleados_fake_gps = asistencias
                                .where("valida_gps = ? OR observaciones ILIKE ?", false, "%Fake GPS%")
                                .pluck(:empleado_id)

          (empleados_tarde + empleados_fake_gps).uniq.count
        end

        def datos_por_empleado(empleados, asistencias, entradas, inicio_mes, fin_mes)
          empleados.map do |empleado|
            asistencias_empleado = asistencias.where(empleado_id: empleado.id)
            entradas_empleado = entradas.where(empleado_id: empleado.id)

            horas = asistencias_empleado.where(tipo_marcacion: "salida")
                                        .sum(:duracion_jornada)
                                        .to_f / 60.0

            {
              empleado_id: empleado.id,
              nombre: "#{empleado.nombre} #{empleado.apellido}",
              horas_trabajadas: horas.round(2),
              tardanzas: contar_tardanzas(entradas_empleado),
              faltas: contar_faltas_empleado(empleado, entradas, inicio_mes, fin_mes),
              fake_gps: asistencias_empleado
                          .where("valida_gps = ? OR observaciones ILIKE ?", false, "%Fake GPS%")
                          .count
            }
          end
        end
      end
    end
  end
end