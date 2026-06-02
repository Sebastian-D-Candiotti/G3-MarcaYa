# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/asistencias/tiempo_real"

module Application
  module UseCases
    module Asistencias
      class TiempoRealTest < Minitest::Test
        def test_devuelve_ultimo_registro_por_empleado
          registros = [
            Domain::Entities::RegistroAsistencia.new(
              id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "SALIDA",
              fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true, duracion_jornada: 480
            ),
            Domain::Entities::RegistroAsistencia.new(
              id: 2, empleado_id: 2, parada_id: 10, tipo_marcacion: "ENTRADA",
              fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true
            )
          ]

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:ultimo_registro_por_empleado) { registros }
          asistencia_repo.define_singleton_method(:ultimo_registro_por_parada) { |_pid| registros }

          use_case = TiempoReal.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar

          assert_equal 2, result.length
        end

        def test_devuelve_registros_por_parada
          registros_parada = [
            Domain::Entities::RegistroAsistencia.new(
              id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
              fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true
            )
          ]

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:ultimo_registro_por_empleado) { [] }
          asistencia_repo.define_singleton_method(:ultimo_registro_por_parada) { |_pid| registros_parada }

          use_case = TiempoReal.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(parada_id: 10)

          assert_equal 1, result.length
          assert_equal 10, result.first.parada_id
        end

        def test_devuelve_array_vacio_cuando_base_vacia
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:ultimo_registro_por_empleado) { [] }
          asistencia_repo.define_singleton_method(:ultimo_registro_por_parada) { |_pid| [] }

          use_case = TiempoReal.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar

          assert_equal [], result
        end
      end
    end
  end
end
