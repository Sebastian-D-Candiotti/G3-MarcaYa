# frozen_string_literal: true

require "minitest/autorun"
require "time"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado_parada"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/domain/services/gps_validation_service"
require_relative "../../../../app/application/use_cases/asistencias/marcar_entrada"
require_relative "../../../../app/application/use_cases/asistencias/marcar_salida"
require_relative "../../../../app/application/use_cases/asistencias/sincronizar_marcaciones_offline"

module Application
  module UseCases
    module Asistencias
      class SincronizarMarcacionesOfflineTest < Minitest::Test
        def empleado
          Domain::Entities::Empleado.new(
            id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez", estado: "activo"
          )
        end

        def parada
          Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada",
            latitud: -12.119, longitud: -77.034, radio_metros: 100, estado: "activa"
          )
        end

        def asignacion
          Domain::Entities::EmpleadoParada.new(
            id: 1, empleado_id: 1, parada_id: 10, activo: true, estado: "activo"
          )
        end

        def empleado_repo
          emp = empleado
          r = Object.new
          r.define_singleton_method(:find_by_id!) { |_id| emp }
          r
        end

        def parada_repo
          par = parada
          r = Object.new
          r.define_singleton_method(:find_by_id!) { |_id| par }
          r
        end

        def empleado_parada_repo
          asig = asignacion
          r = Object.new
          r.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asig }
          r
        end

        def build_use_case(asistencia_repo)
          SincronizarMarcacionesOffline.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: Domain::Services::GpsValidationService
          )
        end

        def test_sincroniza_entrada_guardando_hora_original
          guardado = nil
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:find_by_cliente_marcacion_id) { |_id| nil }
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| nil }
          asistencia_repo.define_singleton_method(:guardar) do |registro|
            guardado = registro
            registro
          end

          use_case = build_use_case(asistencia_repo)
          fecha_original = "2026-06-14T13:20:00Z"

          result = use_case.ejecutar(
            empleado_id: 1,
            marcaciones: [
              {
                cliente_marcacion_id: "offline-1",
                parada_id: 10,
                tipo_marcacion: "ENTRADA",
                latitud: -12.119,
                longitud: -77.034,
                fecha_hora_original: fecha_original
              }
            ]
          )

          assert_equal 1, result[:sincronizados].length
          assert_empty result[:fallidos]
          assert_equal Time.iso8601(fecha_original), guardado.fecha_hora
          assert_equal "offline-1", guardado.cliente_marcacion_id
        end

        def test_retorna_duplicado_si_cliente_marcacion_id_ya_existe
          existente = Domain::Entities::RegistroAsistencia.new(
            id: 99,
            empleado_id: 1,
            parada_id: 10,
            tipo_marcacion: "ENTRADA",
            fecha_hora: Time.iso8601("2026-06-14T13:20:00Z"),
            latitud_registrada: -12.119,
            longitud_registrada: -77.034,
            cliente_marcacion_id: "offline-1"
          )

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:find_by_cliente_marcacion_id) { |_id| existente }

          result = build_use_case(asistencia_repo).ejecutar(
            empleado_id: 1,
            marcaciones: [{ cliente_marcacion_id: "offline-1" }]
          )

          assert_equal 1, result[:duplicados].length
          assert_empty result[:sincronizados]
          assert_empty result[:fallidos]
        end

        def test_retorna_fallido_con_datos_incompletos
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:find_by_cliente_marcacion_id) { |_id| nil }

          result = build_use_case(asistencia_repo).ejecutar(
            empleado_id: 1,
            marcaciones: [
              {
                cliente_marcacion_id: "offline-2",
                tipo_marcacion: "ENTRADA"
              }
            ]
          )

          assert_equal 1, result[:fallidos].length
          assert_match(/invalid value|can't convert|obligatoria|formato/i, result[:fallidos].first[:error])
        end
      end
    end
  end
end
