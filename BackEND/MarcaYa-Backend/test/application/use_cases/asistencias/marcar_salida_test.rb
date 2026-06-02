# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/domain/services/gps_validation_service"
require_relative "../../../../app/application/use_cases/asistencias/marcar_salida"

module Application
  module UseCases
    module Asistencias
      class MarcarSalidaTest < Minitest::Test
        def build_entrada_activa
          Domain::Entities::RegistroAsistencia.new(
            id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
            fecha_hora: Time.now - 3600, # 1 hour ago
            latitud_registrada: -34.603722, longitud_registrada: -58.381592,
            valida_gps: true, duracion_jornada: nil
          )
        end

        def test_marcar_salida_exitosa
          entrada = build_entrada_activa
          registro_creado = nil

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| entrada }
          asistencia_repo.define_singleton_method(:guardar) { |r| registro_creado = r; r }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarSalida.new(
            asistencia_repo: asistencia_repo,
            gps_service: gps_service
          )

          result = use_case.ejecutar(
            empleado_id: 1, parada_id: 10, latitud: -34.603722, longitud: -58.381592
          )

          assert_equal "SALIDA", result.tipo_marcacion
          assert_equal 1, result.empleado_id
          assert_equal 10, result.parada_id
          assert result.valida_gps
          assert result.duracion_jornada.is_a?(Integer)
          assert result.duracion_jornada.positive?
          assert_nil result.observaciones
        end

        def test_rechaza_salida_sin_entrada_activa
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| nil }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarSalida.new(
            asistencia_repo: asistencia_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::AsistenciaNoEncontradaError do
            use_case.ejecutar(empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0)
          end
        end

        def test_calcula_duracion_jornada_en_minutos
          entrada = Domain::Entities::RegistroAsistencia.new(
            id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
            fecha_hora: Time.now - 7200, # 2 hours ago = 120 min
            latitud_registrada: 0, longitud_registrada: 0,
            valida_gps: true
          )

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| entrada }
          asistencia_repo.define_singleton_method(:guardar) { |r| r }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarSalida.new(
            asistencia_repo: asistencia_repo,
            gps_service: gps_service
          )

          result = use_case.ejecutar(
            empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0
          )

          # Duration should be approximately 120 minutes
          assert_in_delta 120, result.duracion_jornada, 1
        end
      end
    end
  end
end
