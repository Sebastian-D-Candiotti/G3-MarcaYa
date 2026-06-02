# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/parada"
require_relative "../../../../app/domain/entities/empleado_parada"
require_relative "../../../../app/domain/entities/registro_asistencia"
require_relative "../../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/domain/services/gps_validation_service"
require_relative "../../../../app/application/use_cases/asistencias/marcar_entrada"

module Application
  module UseCases
    module Asistencias
      class MarcarEntradaTest < Minitest::Test
        def build_empleado
          Domain::Entities::Empleado.new(
            id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez", estado: "activo"
          )
        end

        def build_parada
          Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Entrada Principal",
            latitud: -34.603722, longitud: -58.381592, radio_metros: 50, estado: "activa"
          )
        end

        def build_asignacion_activa
          Domain::Entities::EmpleadoParada.new(
            id: 1, empleado_id: 1, parada_id: 10, activo: true, estado: "activo"
          )
        end

        def test_marcar_entrada_exitoso_dentro_de_geocerca
          empleado = build_empleado
          parada = build_parada
          asignacion = build_asignacion_activa
          registro_creado = nil

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| nil }
          asistencia_repo.define_singleton_method(:guardar) { |r| registro_creado = r; r }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          result = use_case.ejecutar(
            empleado_id: 1,
            parada_id: 10,
            latitud: -34.603722,
            longitud: -58.381592
          )

          assert_equal "ENTRADA", result.tipo_marcacion
          assert_equal 1, result.empleado_id
          assert_equal 10, result.parada_id
          assert result.valida_gps
          assert_nil result.duracion_jornada
          assert_nil result.observaciones
        end

        def test_marcar_entrada_fuera_de_geocerca
          empleado = build_empleado
          parada = build_parada
          asignacion = build_asignacion_activa
          registro_creado = nil

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| nil }
          asistencia_repo.define_singleton_method(:guardar) { |r| registro_creado = r; r }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          result = use_case.ejecutar(
            empleado_id: 1,
            parada_id: 10,
            latitud: -33.0,
            longitud: -58.0
          )

          refute result.valida_gps
          assert_equal "Fuera de zona", result.observaciones
        end

        def test_rechaza_entrada_duplicada
          empleado = build_empleado
          parada = build_parada
          asignacion = build_asignacion_activa
          entrada_activa = Domain::Entities::RegistroAsistencia.new(
            id: 1, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
            fecha_hora: Time.now, latitud_registrada: 0, longitud_registrada: 0,
            valida_gps: true
          )

          asistencia_repo = Object.new
          asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| entrada_activa }

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::EntradaActivaExistenteError do
            use_case.ejecutar(empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0)
          end
        end

        def test_rechaza_empleado_no_encontrado
          asistencia_repo = Object.new

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::UsuarioNoEncontradoError }

          parada_repo = Object.new
          empleado_parada_repo = Object.new
          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::UsuarioNoEncontradoError do
            use_case.ejecutar(empleado_id: 999, parada_id: 10, latitud: 0, longitud: 0)
          end
        end

        def test_rechaza_parada_no_encontrada
          empleado = build_empleado

          asistencia_repo = Object.new

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| raise Domain::Errors::ParadaNoEncontradaError }

          empleado_parada_repo = Object.new
          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::ParadaNoEncontradaError do
            use_case.ejecutar(empleado_id: 1, parada_id: 999, latitud: 0, longitud: 0)
          end
        end

        def test_rechaza_empleado_no_asignado
          empleado = build_empleado
          parada = build_parada

          asistencia_repo = Object.new

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| nil }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::EmpleadoNoAsignadoParadaError do
            use_case.ejecutar(empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0)
          end
        end

        def test_rechaza_asignacion_inactiva
          empleado = build_empleado
          parada = build_parada
          asignacion_inactiva = Domain::Entities::EmpleadoParada.new(
            id: 1, empleado_id: 1, parada_id: 10, activo: false, estado: "inactivo"
          )

          asistencia_repo = Object.new

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion_inactiva }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::EmpleadoNoAsignadoParadaError do
            use_case.ejecutar(empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0)
          end
        end

        def test_rechaza_parada_inactiva
          empleado = build_empleado
          parada_inactiva = Domain::Entities::Parada.new(
            id: 10, obra_id: 1, nombre: "Inactiva",
            latitud: -34.6, longitud: -58.3, estado: "inactiva"
          )
          asignacion = build_asignacion_activa

          asistencia_repo = Object.new

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }

          parada_repo = Object.new
          parada_repo.define_singleton_method(:find_by_id!) { |_id| parada_inactiva }

          empleado_parada_repo = Object.new
          empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }

          gps_service = Domain::Services::GpsValidationService

          use_case = MarcarEntrada.new(
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: parada_repo,
            empleado_parada_repo: empleado_parada_repo,
            gps_service: gps_service
          )

          assert_raises Domain::Errors::ParadaInactivaError do
            use_case.ejecutar(empleado_id: 1, parada_id: 10, latitud: 0, longitud: 0)
          end
        end
      end
    end
  end
end
