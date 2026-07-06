# frozen_string_literal: true

require "minitest/autorun"

# Require domain entities needed by helper methods
require_relative "../../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/entities/asignacion"
require_relative "../../../../app/domain/entities/alerta_ausencia"
require_relative "../../../../app/application/use_cases/alertas/evaluar_ausencias"

module Application
  module UseCases
    module Alertas
      class EvaluarAusenciasTest < Minitest::Test
        def setup_fixtures; end
        def teardown_fixtures; end

        # Helper: build a mock Obra domain entity with a Time-typed hora_inicio
        def build_obra(id:, hora_inicio:, tolerancia_entrada_min: 15, empresa_id: 1)
          Domain::Entities::Obra.new(
            id: id,
            empresa_id: empresa_id,
            nombre: "Obra #{id}",
            latitud: -12.0,
            longitud: -77.0,
            hora_inicio: hora_inicio,
            hora_fin: Time.new(2000, 1, 1, 17, 0, 0),
            tolerancia_entrada_min: tolerancia_entrada_min,
            estado: "activa"
          )
        end

        def build_asignacion(empleado_id:, obra_id: 1)
          Domain::Entities::Asignacion.new(
            id: 1,
            empleado_id: empleado_id,
            obra_id: obra_id,
            estado: "activo"
          )
        end

        def build_alerta(id:, empleado_id:, obra_id:, empresa_id:, fecha:, estado: "pendiente")
          Domain::Entities::AlertaAusencia.new(
            id: id, empleado_id: empleado_id, obra_id: obra_id,
            empresa_id: empresa_id, fecha: fecha, estado: estado
          )
        end

        # Use date 2000-01-01 (like t.time column in Rails) with early hour (past relative to current time)
        def past_hora_inicio
          Time.new(2000, 1, 1, 6, 0, 0) # 6 AM — well before current time (~17:00)
        end

        # Use date 2000-01-01 with late hour (future relative to current time)
        def future_hora_inicio
          Time.new(2000, 1, 1, 23, 0, 0) # 11 PM — well after current time (~17:00)
        end

        def test_no_evalua_cuando_no_hay_obras_activas
          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) { [] }

          asistencia_repo = Object.new
          alerta_repo = Object.new

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal({ evaluadas: 0, creadas: 0, resueltas: 0 }, result)
        end

        def test_crea_alerta_cuando_empleado_no_tiene_entrada_hoy
          obra = build_obra(id: 1, hora_inicio: past_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_empleado_id| false }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) { |_eid, _fecha| nil }
          guardado = []
          alerta_repo.define_singleton_method(:guardar) do |alerta|
            guardado << alerta
            alerta
          end

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 1, result[:evaluadas]
          assert_equal 1, result[:creadas]
          assert_equal 0, result[:resueltas]
          assert_equal 1, guardado.length
          assert_equal 42, guardado[0].empleado_id
          assert_equal 1, guardado[0].obra_id
          assert_equal "pendiente", guardado[0].estado
        end

        def test_no_crea_alerta_si_empleado_tiene_entrada_hoy
          obra = build_obra(id: 1, hora_inicio: past_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_empleado_id| true }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) { |_eid, _fecha| nil }
          actualizados = []
          alerta_repo.define_singleton_method(:actualizar_estado) { |id, estado| actualizados << { id: id, estado: estado } }

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 1, result[:evaluadas]
          assert_equal 0, result[:creadas]
          assert_equal 0, result[:resueltas]
          assert_empty actualizados
        end

        def test_resuelve_alerta_existente_cuando_empleado_tiene_entrada
          obra = build_obra(id: 1, hora_inicio: past_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)
          fecha_hoy = Date.today
          alerta_existente = build_alerta(id: 1, empleado_id: 42, obra_id: 1, empresa_id: 1, fecha: fecha_hoy)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_empleado_id| true }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) do |eid, fecha|
            alerta_existente if eid == 42 && fecha == fecha_hoy
          end
          actualizados = []
          alerta_repo.define_singleton_method(:actualizar_estado) do |id, estado|
            actualizados << { id: id, estado: estado }
          end

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 1, result[:evaluadas]
          assert_equal 0, result[:creadas]
          assert_equal 1, result[:resueltas]
          assert_equal 1, actualizados.length
          assert_equal 1, actualizados[0][:id]
          assert_equal "resuelta", actualizados[0][:estado]
        end

        def test_omite_empleados_si_no_ha_pasado_tolerancia
          obra = build_obra(id: 1, hora_inicio: future_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          alerta_repo = Object.new

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 0, result[:evaluadas]
          assert_equal 0, result[:creadas]
          assert_equal 0, result[:resueltas]
        end

        def test_procesa_varias_obras_y_empleados
          obra_a = build_obra(id: 1, hora_inicio: past_hora_inicio)
          obra_b = build_obra(id: 2, hora_inicio: past_hora_inicio)

          asignacion_a1 = build_asignacion(empleado_id: 10, obra_id: 1)
          asignacion_a2 = build_asignacion(empleado_id: 11, obra_id: 1)
          asignacion_b1 = build_asignacion(empleado_id: 20, obra_id: 2)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [
              { obra: obra_a, asignaciones: [asignacion_a1, asignacion_a2] },
              { obra: obra_b, asignaciones: [asignacion_b1] }
            ]
          end

          call_count = 0
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) do |_empleado_id|
            call_count += 1
            false
          end

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) { |_eid, _fecha| nil }
          guardados = []
          alerta_repo.define_singleton_method(:guardar) do |alerta|
            guardados << alerta
            alerta
          end

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 3, result[:evaluadas]
          assert_equal 3, result[:creadas]
          assert_equal 0, result[:resueltas]
          assert_equal 3, guardados.length
          assert_equal 3, call_count
          empleado_ids = guardados.map(&:empleado_id)
          assert_includes empleado_ids, 10
          assert_includes empleado_ids, 11
          assert_includes empleado_ids, 20
        end

        def test_no_crea_duplicado_cuando_alerta_ya_existe
          obra = build_obra(id: 1, hora_inicio: past_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)
          fecha_hoy = Date.today
          alerta_existente = build_alerta(id: 5, empleado_id: 42, obra_id: 1, empresa_id: 1, fecha: fecha_hoy)

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_eid| false }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) { |_eid, _fecha| alerta_existente }
          guardados = []
          alerta_repo.define_singleton_method(:guardar) do |a|
            guardados << a
            a
          end

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 1, result[:evaluadas]
          assert_equal 0, result[:creadas]
          assert_equal 0, result[:resueltas]
          assert_empty guardados
        end

        def test_no_resuelve_alerta_que_no_es_pendiente
          obra = build_obra(id: 1, hora_inicio: past_hora_inicio, tolerancia_entrada_min: 0)
          asignacion = build_asignacion(empleado_id: 42, obra_id: 1)
          fecha_hoy = Date.today
          alerta_resuelta = build_alerta(id: 1, empleado_id: 42, obra_id: 1, empresa_id: 1,
                                          fecha: fecha_hoy, estado: "resuelta")

          obra_repo = Object.new
          obra_repo.define_singleton_method(:listar_activas_con_asignaciones) do
            [{ obra: obra, asignaciones: [asignacion] }]
          end

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_hoy) { |_eid| true }

          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:buscar_por_empleado_y_fecha) { |_eid, _fecha| alerta_resuelta }
          actualizados = []
          alerta_repo.define_singleton_method(:actualizar_estado) { |id, estado| actualizados << { id: id, estado: estado } }

          use_case = EvaluarAusencias.new(
            alerta_repo: alerta_repo,
            obra_repo: obra_repo,
            asistencia_repo: asistencia_repo
          )

          result = use_case.ejecutar

          assert_equal 1, result[:evaluadas]
          assert_equal 0, result[:creadas]
          assert_equal 0, result[:resueltas]
          assert_empty actualizados
        end
      end
    end
  end
end
