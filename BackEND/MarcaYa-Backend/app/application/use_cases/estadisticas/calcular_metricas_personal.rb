# frozen_string_literal: true

require "date"

module Application
  module UseCases
    module Estadisticas
      class CalcularMetricasPersonal
        def initialize(obra_repo:, parada_repo:, asistencia_repo:, empleado_repo:, empleado_parada_repo:)
          @obra_repo = obra_repo
          @parada_repo = parada_repo
          @asistencia_repo = asistencia_repo
          @empleado_repo = empleado_repo
          @empleado_parada_repo = empleado_parada_repo
        end

        def call(obra_id:, periodo:)
          obra = @obra_repo.find_by_id!(obra_id)
          paradas = @parada_repo.listar_por_obra(obra_id)

          periodo = Time.current.strftime("%Y-%m") if periodo.nil? || periodo.empty?

          return empty_metrics(obra, periodo) if paradas.empty?

          parada_ids = paradas.map(&:id)
          anio, mes = periodo.split("-").map(&:to_i)
          inicio = Time.new(anio, mes, 1)
          fin = last_second_of_month(anio, mes)

          asistencias = @asistencia_repo.por_paradas_y_periodo(parada_ids, inicio, fin)
          empleado_ids = @empleado_parada_repo.empleado_ids_por_paradas(parada_ids)
          empleados = @empleado_repo.por_ids_y_estado(empleado_ids, "activo")

          return empty_metrics(obra, periodo) if asistencias.empty?

          entradas = asistencias.select(&:entrada?)
          salidas = asistencias.select(&:salida?)

          horas_totales = calc_horas_totales(salidas)
          dias_trabajados = calc_dias_trabajados(entradas)
          tardanzas_total, tardanzas = calc_tardanzas(entradas, obra)
          puntualidad_porcentaje = calc_puntualidad(entradas.size, tardanzas_total)
          dias_del_periodo = dias_del_mes(anio, mes)
          fake_gps_asistencias = detect_fake_gps(asistencias)
          fake_gps_intentos = fake_gps_asistencias.size
          empleados_con_irregularidades_ids = calc_irregularidades_ids(tardanzas, fake_gps_asistencias)
          faltas_total = calc_faltas_total(empleados, entradas, dias_del_periodo)
          horas_promedio = dias_trabajados > 0 ? (horas_totales / dias_trabajados).round(2) : 0.0

          datos_por_empleado = build_datos_por_empleado(
            empleados, entradas, salidas, tardanzas,
            fake_gps_asistencias, dias_del_periodo
          )

          Domain::Entities::MetricasObra.new(
            obra_id: obra.id,
            obra_nombre: obra.nombre,
            periodo: periodo,
            horas_promedio: horas_promedio,
            horas_totales: horas_totales,
            puntualidad_porcentaje: puntualidad_porcentaje,
            dias_trabajados: dias_trabajados,
            tardanzas_total: tardanzas_total,
            faltas_total: faltas_total,
            empleados_activos: empleados.size,
            empleados_con_irregularidades: empleados_con_irregularidades_ids.size,
            fake_gps_intentos: fake_gps_intentos,
            datos_por_empleado: datos_por_empleado
          )
        end

        private

        def empty_metrics(obra, periodo)
          Domain::Entities::MetricasObra.new(
            obra_id: obra.id,
            obra_nombre: obra.nombre,
            periodo: periodo
          )
        end

        def calc_horas_totales(salidas)
          (salidas.sum(&:duracion_jornada).to_f / 60.0).round(2)
        end

        def calc_dias_trabajados(entradas)
          entradas.map { |a| to_date(a.fecha_hora) }.uniq.size
        end

        def calc_tardanzas(entradas, obra)
          hora_inicio = obra.hora_inicio
          tolerancia = obra.tolerancia_entrada_min || 0

          tardanzas = entradas.select do |a|
            t = a.fecha_hora
            reference = Time.new(t.year, t.month, t.day,
                                 hora_inicio.hour, hora_inicio.min, hora_inicio.sec)
            t > (reference + (tolerancia * 60))
          end
          [tardanzas.size, tardanzas]
        end

        def calc_puntualidad(total_entradas, tardanzas_total)
          return 0.0 if total_entradas.zero?

          ((total_entradas - tardanzas_total).to_f / total_entradas * 100).round(2)
        end

        def dias_del_mes(anio, mes)
          ultimo = last_day_of_month(anio, mes)
          (Date.new(anio, mes, 1)..Date.new(anio, mes, ultimo)).to_a
        end

        def detect_fake_gps(asistencias)
          asistencias.select do |a|
            !a.valida_gps ||
              a.observaciones.to_s.upcase.include?("FAKE GPS") ||
              a.observaciones.to_s.upcase.include?("FAKE_GPS")
          end
        end

        def calc_irregularidades_ids(tardanzas, fake_gps_asistencias)
          (tardanzas.map(&:empleado_id) + fake_gps_asistencias.map(&:empleado_id)).uniq
        end

        def calc_faltas_total(empleados, entradas, dias_del_periodo)
          empleados.sum do |empleado|
            emp_dias = entradas
              .select { |a| a.empleado_id == empleado.id }
              .map { |a| to_date(a.fecha_hora) }
              .uniq
            (dias_del_periodo - emp_dias).size
          end
        end

        def build_datos_por_empleado(empleados, entradas, salidas, tardanzas, fake_gps_asistencias, dias_del_periodo)
          empleados.map do |empleado|
            emp_entradas = entradas.select { |a| a.empleado_id == empleado.id }
            emp_salidas = salidas.select { |a| a.empleado_id == empleado.id }
            emp_tardanzas = tardanzas.select { |a| a.empleado_id == empleado.id }
            emp_fake_gps = fake_gps_asistencias.select { |a| a.empleado_id == empleado.id }

            emp_horas = (emp_salidas.sum(&:duracion_jornada).to_f / 60.0).round(2)
            emp_dias = emp_entradas.map { |a| to_date(a.fecha_hora) }.uniq
            emp_faltas = (dias_del_periodo - emp_dias).size

            {
              empleado_id: empleado.id,
              nombre: "#{empleado.nombre} #{empleado.apellido}",
              horas_trabajadas: emp_horas,
              tardanzas: emp_tardanzas.size,
              faltas: emp_faltas,
              fake_gps: emp_fake_gps.size
            }
          end
        end

        def to_date(time)
          Date.new(time.year, time.month, time.day)
        end

        def last_day_of_month(year, month)
          mdays = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
          return 29 if month == 2 && Date.leap?(year)

          mdays[month]
        end

        def last_second_of_month(year, month)
          day = last_day_of_month(year, month)
          Time.new(year, month, day, 23, 59, 59)
        end
      end
    end
  end
end
