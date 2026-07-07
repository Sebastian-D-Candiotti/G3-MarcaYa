# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class ConstruirSnapshot
        def call(empresa:, tipo_periodo:, fecha_inicio:, fecha_fin:)
          registros = registros_de_asistencia(empresa, fecha_inicio, fecha_fin)
          alertas = alertas_de_ausencia(empresa, fecha_inicio, fecha_fin)
          empleados = empleados_resumen(registros, alertas)

          horas = registros
                  .select { |r| r.tipo_marcacion == "SALIDA" && r.valida_gps && r.duracion_jornada.present? }
                  .sum { |r| r.duracion_jornada.to_f / 60.0 }

          {
            empresa: {
              id: empresa.id,
              nombre: empresa.nombre_empresa,
              ruc: empresa.ruc
            },
            periodo: {
              tipo: tipo_periodo,
              fecha_inicio: fecha_inicio.iso8601,
              fecha_fin: fecha_fin.iso8601
            },
            generado_en: Time.current.iso8601,
            resumen: {
              empleados_incluidos: empleados.length,
              total_marcaciones: registros.length,
              entradas: registros.count { |r| r.tipo_marcacion == "ENTRADA" },
              salidas: registros.count { |r| r.tipo_marcacion == "SALIDA" },
              horas_trabajadas: horas.round(2),
              tardanzas: contar_por_observacion(registros, "tardanza"),
              inasistencias: alertas.length,
              justificaciones: 0,
              marcaciones_invalidas: registros.count { |r| !r.valida_gps },
              fake_gps: registros.count { |r| r.observaciones.to_s.downcase.include?("fake") },
              porcentaje_gps_valido: porcentaje(registros.count { |r| r.valida_gps }, registros.length)
            },
            empleados: empleados,
            limitaciones: {
              justificaciones: "No existe tabla de justificaciones en main al momento de esta implementacion.",
              fake_gps: "Se cuenta solo cuando observaciones contiene la palabra fake; no hay columna persistida is_mocked."
            }
          }
        end

        private

        def registros_de_asistencia(empresa, fecha_inicio, fecha_fin)
          Infrastructure::Orm::AsistenciaRecord
            .joins(parada: :obra)
            .includes(:empleado, parada: :obra)
            .where(obras: { empresa_id: empresa.id })
            .where(fecha_hora: fecha_inicio.beginning_of_day..fecha_fin.end_of_day)
            .order(:fecha_hora)
            .to_a
        end

        def alertas_de_ausencia(empresa, fecha_inicio, fecha_fin)
          Infrastructure::Orm::AlertaAusenciaRecord
            .includes(:empleado, :obra)
            .where(empresa_id: empresa.id, fecha: fecha_inicio..fecha_fin)
            .to_a
        end

        def empleados_resumen(registros, alertas)
          empleados_ids = (registros.map(&:empleado_id) + alertas.map(&:empleado_id)).uniq
          empleados = Infrastructure::Orm::EmpleadoRecord.where(id: empleados_ids).index_by(&:id)
          registros_por_empleado = registros.group_by(&:empleado_id)
          alertas_por_empleado = alertas.group_by(&:empleado_id)

          empleados_ids.sort.map do |empleado_id|
            empleado = empleados[empleado_id]
            registros_empleado = registros_por_empleado.fetch(empleado_id, [])
            alertas_empleado = alertas_por_empleado.fetch(empleado_id, [])
            horas = registros_empleado
                    .select { |r| r.tipo_marcacion == "SALIDA" && r.valida_gps && r.duracion_jornada.present? }
                    .sum { |r| r.duracion_jornada.to_f / 60.0 }

            {
              empleado_id: empleado_id,
              nombre: [empleado&.nombre, empleado&.apellido].compact.join(" ").presence || "Empleado #{empleado_id}",
              dni: empleado&.dni,
              total_marcaciones: registros_empleado.length,
              entradas: registros_empleado.count { |r| r.tipo_marcacion == "ENTRADA" },
              salidas: registros_empleado.count { |r| r.tipo_marcacion == "SALIDA" },
              horas_trabajadas: horas.round(2),
              tardanzas: contar_por_observacion(registros_empleado, "tardanza"),
              inasistencias: alertas_empleado.length,
              marcaciones_invalidas: registros_empleado.count { |r| !r.valida_gps },
              fake_gps: registros_empleado.count { |r| r.observaciones.to_s.downcase.include?("fake") }
            }
          end
        end

        def contar_por_observacion(registros, texto)
          registros.count { |r| r.observaciones.to_s.downcase.include?(texto) }
        end

        def porcentaje(valor, total)
          return 0.0 if total.zero?

          ((valor.to_f / total) * 100).round(2)
        end
      end
    end
  end
end
