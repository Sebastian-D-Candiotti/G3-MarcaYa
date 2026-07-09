# frozen_string_literal: true

module Domain
  module Entities
    class MetricasObra
      attr_reader :obra_id, :obra_nombre, :periodo, :horas_promedio, :horas_totales,
                  :puntualidad_porcentaje, :dias_trabajados, :tardanzas_total,
                  :faltas_total, :empleados_activos, :empleados_con_irregularidades,
                  :fake_gps_intentos, :datos_por_empleado

      def initialize(obra_id:, obra_nombre:, periodo:, horas_promedio: 0.0, horas_totales: 0.0,
                     puntualidad_porcentaje: 0.0, dias_trabajados: 0, tardanzas_total: 0,
                     faltas_total: 0, empleados_activos: 0, empleados_con_irregularidades: 0,
                     fake_gps_intentos: 0, datos_por_empleado: [])
        @obra_id = obra_id
        @obra_nombre = obra_nombre
        @periodo = periodo
        @horas_promedio = horas_promedio
        @horas_totales = horas_totales
        @puntualidad_porcentaje = puntualidad_porcentaje
        @dias_trabajados = dias_trabajados
        @tardanzas_total = tardanzas_total
        @faltas_total = faltas_total
        @empleados_activos = empleados_activos
        @empleados_con_irregularidades = empleados_con_irregularidades
        @fake_gps_intentos = fake_gps_intentos
        @datos_por_empleado = datos_por_empleado
      end
    end
  end
end
