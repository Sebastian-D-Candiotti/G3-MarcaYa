# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/metricas_obra"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/application/use_cases/estadisticas/calcular_metricas_personal"
require_relative "../../../../app/domain/errors"

module Application
  module UseCases
    module Estadisticas
      class CalcularMetricasPersonalTest < Minitest::Test
        def setup
          @obra = Domain::Entities::Obra.new(
            id: 1, empresa_id: 1, nombre: "Obra Test",
            latitud: -12.0, longitud: -77.0,
            hora_inicio: Time.new(2000, 1, 1, 8, 0, 0),
            hora_fin: Time.new(2000, 1, 1, 17, 0, 0),
            tolerancia_entrada_min: 5
          )
          @parada = Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Parada 1",
            latitud: -12.0, longitud: -77.0
          )
          @empleado = Domain::Entities::Empleado.new(
            id: 100, usuario_id: 1, nombre: "Juan", apellido: "Pérez", estado: "activo"
          )
          @empleado2 = Domain::Entities::Empleado.new(
            id: 101, usuario_id: 2, nombre: "María", apellido: "López", estado: "activo"
          )
        end

        # --- Happy path: single employee with different scenarios ---

        def test_call_returns_metricas_obra_with_calculated_values
          entrada_on_time = build_entrada(1, 100, 2026, 6, 1, 8, 0, true)
          entrada_tardy = build_entrada(2, 100, 2026, 6, 2, 8, 30, true)
          entrada_fake_gps = build_entrada(3, 100, 2026, 6, 3, 8, 0, false)
          salida_1 = build_salida(4, 100, 2026, 6, 1, 17, 0, 480)
          salida_2 = build_salida(5, 100, 2026, 6, 2, 17, 0, 510)
          salida_3 = build_salida(6, 100, 2026, 6, 3, 17, 0, 480)

          all_asistencias = [entrada_on_time, entrada_tardy, entrada_fake_gps, salida_1, salida_2, salida_3]
          result = execute_use_case(asistencias: all_asistencias, empleados: [@empleado], empleado_ids: [100])

          assert_equal 1, result.obra_id
          assert_equal "Obra Test", result.obra_nombre
          assert_equal "2026-06", result.periodo
          assert_equal 24.5, result.horas_totales # (480 + 510 + 480) / 60
          assert_in_delta 8.17, result.horas_promedio, 0.01
          assert_equal 3, result.dias_trabajados
          assert_equal 1, result.tardanzas_total
          assert_in_delta 66.67, result.puntualidad_porcentaje, 0.01
          assert_equal 1, result.fake_gps_intentos
          assert_equal 1, result.empleados_activos
          assert_equal 1, result.empleados_con_irregularidades
          assert_equal 27, result.faltas_total

          assert_equal 1, result.datos_por_empleado.size
          entry = result.datos_por_empleado.first
          assert_equal 100, entry[:empleado_id]
          assert_equal "Juan Pérez", entry[:nombre]
          assert_equal 24.5, entry[:horas_trabajadas]
          assert_equal 1, entry[:tardanzas]
          assert_equal 27, entry[:faltas]
          assert_equal 1, entry[:fake_gps]
        end

        # --- Multiple employees test ---

        def test_call_with_multiple_employees
          entrada_e1 = build_entrada(1, 100, 2026, 6, 1, 8, 0, true)
          entrada_e2 = build_entrada(2, 101, 2026, 6, 1, 8, 0, true)
          salida_e1 = build_salida(3, 100, 2026, 6, 1, 17, 0, 480)
          salida_e2 = build_salida(4, 101, 2026, 6, 1, 17, 0, 480)

          result = execute_use_case(
            asistencias: [entrada_e1, entrada_e2, salida_e1, salida_e2],
            empleados: [@empleado, @empleado2],
            empleado_ids: [100, 101]
          )

          assert_equal 16.0, result.horas_totales # (480 + 480) / 60
          assert_equal 16.0, result.horas_promedio # horas_totales / dias_trabajados = 16 / 1
          assert_equal 2, result.empleados_activos
          assert_equal 2, result.datos_por_empleado.size
        end

        # --- Fake GPS detection via observaciones ---

        def test_detects_fake_gps_via_observaciones
          entrada = build_entrada(1, 100, 2026, 6, 1, 8, 0, true, "Fake GPS detected")
          salida = build_salida(2, 100, 2026, 6, 1, 17, 0, 480)

          result = execute_use_case(asistencias: [entrada, salida], empleados: [@empleado], empleado_ids: [100])

          assert_equal 1, result.fake_gps_intentos
          assert_equal 1, result.empleados_con_irregularidades
        end

        # --- Obra sin paradas ---

        def test_call_without_paradas_returns_zeros
          obra_repo = build_obra_repo
          parada_repo = Object.new
          parada_repo.define_singleton_method(:listar_por_obra) { |_| [] }

          use_case = CalcularMetricasPersonal.new(
            obra_repo: obra_repo,
            parada_repo: parada_repo,
            asistencia_repo: Object.new,
            empleado_repo: Object.new,
            empleado_parada_repo: Object.new
          )
          result = use_case.call(obra_id: 1, periodo: "2026-06")

          assert_equal 0.0, result.horas_totales
          assert_equal 0, result.empleados_activos
          assert_equal 0, result.datos_por_empleado.size
        end

        # --- Sin asistencias ---

        def test_call_without_asistencias_returns_zeros
          result = execute_use_case(asistencias: [], empleados: [@empleado], empleado_ids: [100])

          assert_equal 0.0, result.horas_totales
          assert_equal 0.0, result.horas_promedio
          assert_equal 0, result.dias_trabajados
          assert_equal 0, result.tardanzas_total
          assert_equal 0.0, result.puntualidad_porcentaje
          assert_equal 0, result.fake_gps_intentos
          assert_equal 0, result.empleados_activos
          assert_equal 0, result.empleados_con_irregularidades
          assert_equal 0, result.faltas_total
          assert_equal 0, result.datos_por_empleado.size
        end

        # --- Obra no encontrada ---

        def test_call_raises_error_when_obra_not_found
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) do |_id|
            raise Domain::Errors::ObraNoEncontradaError
          end
          parada_repo = Object.new
          parada_repo.define_singleton_method(:listar_por_obra) { |_| [] }

          use_case = CalcularMetricasPersonal.new(
            obra_repo: obra_repo,
            parada_repo: parada_repo,
            asistencia_repo: Object.new,
            empleado_repo: Object.new,
            empleado_parada_repo: Object.new
          )

          assert_raises Domain::Errors::ObraNoEncontradaError do
            use_case.call(obra_id: 999, periodo: "2026-06")
          end
        end

        private

        def build_entrada(id, empleado_id, year, month, day, hour, min, valida_gps, observaciones = nil)
          Domain::Entities::RegistroAsistencia.new(
            id: id, empleado_id: empleado_id, parada_id: 10,
            tipo_marcacion: "ENTRADA",
            fecha_hora: Time.new(year, month, day, hour, min, 0),
            latitud_registrada: -12.0, longitud_registrada: -77.0,
            valida_gps: valida_gps, observaciones: observaciones
          )
        end

        def build_salida(id, empleado_id, year, month, day, hour, min, duracion)
          Domain::Entities::RegistroAsistencia.new(
            id: id, empleado_id: empleado_id, parada_id: 10,
            tipo_marcacion: "SALIDA",
            fecha_hora: Time.new(year, month, day, hour, min, 0),
            latitud_registrada: -12.0, longitud_registrada: -77.0,
            duracion_jornada: duracion, valida_gps: true
          )
        end

        def execute_use_case(asistencias:, empleados:, empleado_ids:)
          obra_repo = build_obra_repo
          parada_repo = build_parada_repo

          emp_list = empleados
          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:por_ids_y_estado) { |_, _| emp_list }

          emp_ids = empleado_ids
          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:empleado_ids_por_paradas) { |_| emp_ids }

          data = asistencias
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:por_paradas_y_periodo) { |_, _, _| data }
          asistencia_repo.define_singleton_method(:por_paradas_y_periodo_y_tipo) { |_, _, _, _| [] }

          use_case = CalcularMetricasPersonal.new(
            obra_repo: obra_repo,
            parada_repo: parada_repo,
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            empleado_parada_repo: empleado_parada_repo
          )
          use_case.call(obra_id: 1, periodo: "2026-06")
        end

        def build_obra_repo
          obra = @obra
          repo = Object.new
          repo.define_singleton_method(:find_by_id!) { |_id| obra }
          repo
        end

        def build_parada_repo
          parada = @parada
          repo = Object.new
          repo.define_singleton_method(:listar_por_obra) { |_| [parada] }
          repo
        end
      end
    end
  end
end
