# frozen_string_literal: true

module Serializer
  module EstadisticasSerializer
    def self.as_json(metricas)
      return nil if metricas.nil?

      {
        obra_id: metricas.obra_id,
        obra_nombre: metricas.obra_nombre,
        periodo: metricas.periodo,
        horas_totales: metricas.horas_totales,
        horas_promedio: metricas.horas_promedio,
        dias_trabajados: metricas.dias_trabajados,
        tardanzas_total: metricas.tardanzas_total,
        puntualidad_porcentaje: metricas.puntualidad_porcentaje,
        faltas_total: metricas.faltas_total,
        empleados_activos: metricas.empleados_activos,
        empleados_con_irregularidades: metricas.empleados_con_irregularidades,
        fake_gps_intentos: metricas.fake_gps_intentos,
        datos_por_empleado: metricas.datos_por_empleado
      }
    end
  end
end
