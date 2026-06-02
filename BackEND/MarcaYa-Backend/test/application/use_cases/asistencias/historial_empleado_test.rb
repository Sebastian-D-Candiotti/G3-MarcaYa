# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/asistencias/historial_empleado"

module Application
  module UseCases
    module Asistencias
      class HistorialEmpleadoTest < Minitest::Test
        def test_devuelve_registros_para_empleado
          registros = [
            Domain::Entities::RegistroAsistencia.new(
              id: 1, empleado_id: 5, parada_id: 10, tipo_marcacion: "ENTRADA",
              fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
              valida_gps: true
            )
          ]

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:historial_por_empleado) { |_eid| registros }

          use_case = HistorialEmpleado.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 5)

          assert_equal 1, result.length
          assert_equal 5, result.first.empleado_id
        end

        def test_devuelve_array_vacio_cuando_no_hay_registros
          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:historial_por_empleado) { |_eid| [] }

          use_case = HistorialEmpleado.new(asistencia_repo: asistencia_repo)
          result = use_case.ejecutar(empleado_id: 999)

          assert_equal [], result
        end
      end
    end
  end
end
