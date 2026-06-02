# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/asistencias/historial_personal"

module Application
  module UseCases
    module Asistencias
      class HistorialPersonalTest < Minitest::Test
        def test_devuelve_registros_ordenados_por_fecha_desc
          registros = [
            Domain::Entities::RegistroAsistencia.new(
              id: 2, empleado_id: 1, parada_id: 10, tipo_marcacion: "SALIDA",
              fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true, duracion_jornada: 480
            ),
            Domain::Entities::RegistroAsistencia.new(
              id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
              fecha_hora: Time.now - 3600, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true
            )
          ]

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:historial_por_empleado) { |_eid| registros }

          use_case = HistorialPersonal.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 1)

          assert_equal 2, result.length
          assert_equal "SALIDA", result.first.tipo_marcacion
          assert_equal "ENTRADA", result.last.tipo_marcacion
        end

        def test_devuelve_array_vacio_cuando_no_hay_registros
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:historial_por_empleado) { |_eid| [] }

          use_case = HistorialPersonal.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 999)

          assert_equal [], result
        end
      end
    end
  end
end
