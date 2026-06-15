# frozen_string_literal: true

require "test_helper"
require_relative "../../../app/domain/entities/empleado"
require_relative "../../../app/domain/entities/parada"
require_relative "../../../app/domain/entities/empleado_parada"
require_relative "../../../app/domain/entities/registro_asistencia"
require_relative "../../../app/domain/value_objects/tipo_marcacion"
require_relative "../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../app/domain/errors"
require_relative "../../../app/domain/services/gps_validation_service"
require_relative "../../../app/application/use_cases/asistencias/marcar_entrada"
require_relative "../../../app/application/use_cases/asistencias/marcar_salida"
require_relative "../../../app/application/facades/asistencia_facade"

module Application
  module Facades
    class AsistenciaFacadePushTest < ActiveJob::TestCase
      REGISTRO_ID = 42

      def setup
        empleado = Domain::Entities::Empleado.new(
          id: 1, usuario_id: 1, nombre: "Juan", apellido: "Perez", estado: "activo"
        )
        parada = Domain::Entities::Parada.new(
          id: 10, obra_id: 1, nombre: "Entrada Principal",
          latitud: -34.603722, longitud: -58.381592, radio_metros: 50, estado: "activa"
        )
        asignacion = Domain::Entities::EmpleadoParada.new(
          id: 1, empleado_id: 1, parada_id: 10, activo: true, estado: "activo"
        )

        @asistencia_repo = Object.new
        @empleado_repo = Object.new
        @parada_repo = Object.new
        @empleado_parada_repo = Object.new

        @asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| nil }
        @empleado_repo.define_singleton_method(:find_by_id!) { |_id| empleado }
        @parada_repo.define_singleton_method(:find_by_id!) { |_id| parada }
        @empleado_parada_repo.define_singleton_method(:buscar_asignacion) { |_eid, _pid| asignacion }
      end

      def guardar_asistencia(registro)
        Domain::Entities::RegistroAsistencia.new(
          id: REGISTRO_ID,
          empleado_id: registro.empleado_id,
          parada_id: registro.parada_id,
          tipo_marcacion: registro.tipo_marcacion,
          fecha_hora: registro.fecha_hora,
          latitud_registrada: registro.latitud_registrada,
          longitud_registrada: registro.longitud_registrada,
          valida_gps: registro.valida_gps,
          duracion_jornada: registro.duracion_jornada,
          observaciones: registro.observaciones
        )
      end

      def build_entrada_facade
        # Capture in local variables so define_singleton_method closures work
        guardar = method(:guardar_asistencia)

        asistencia_repo = @asistencia_repo
        asistencia_repo.define_singleton_method(:guardar) { |r| guardar.call(r) }

        AsistenciaFacade.new(
          asistencia_repo: asistencia_repo,
          empleado_repo: @empleado_repo,
          parada_repo: @parada_repo,
          empleado_parada_repo: @empleado_parada_repo,
          gps_service: Domain::Services::GpsValidationService
        )
      end

      def build_salida_facade
        entrada = Domain::Entities::RegistroAsistencia.new(
          id: 5, empleado_id: 1, parada_id: 10, tipo_marcacion: "ENTRADA",
          fecha_hora: Time.now - 3600,
          latitud_registrada: -34.603722, longitud_registrada: -58.381592,
          valida_gps: true, duracion_jornada: nil
        )
        guardar = method(:guardar_asistencia)

        asistencia_repo = @asistencia_repo
        asistencia_repo.define_singleton_method(:buscar_entrada_activa) { |_eid| entrada }
        asistencia_repo.define_singleton_method(:guardar) { |r| guardar.call(r) }

        AsistenciaFacade.new(
          asistencia_repo: asistencia_repo,
          empleado_repo: @empleado_repo,
          parada_repo: @parada_repo,
          empleado_parada_repo: @empleado_parada_repo,
          gps_service: Domain::Services::GpsValidationService
        )
      end

      def test_marcar_entrada_enqueues_push_notification_job
        facade = build_entrada_facade

        result = facade.marcar_entrada(
          empleado_id: 1, parada_id: 10,
          latitud: -34.603722, longitud: -58.381592
        )

        assert_equal "ENTRADA", result.tipo_marcacion
        assert_equal REGISTRO_ID, result.id

        assert_enqueued_with(
          job: SendPushNotificationJob,
          args: [result.empleado_id, result.id],
          queue: "push_notifications"
        )
      end

      def test_marcar_salida_enqueues_push_notification_job
        facade = build_salida_facade

        result = facade.marcar_salida(
          empleado_id: 1, parada_id: 10,
          latitud: -34.603722, longitud: -58.381592
        )

        assert_equal "SALIDA", result.tipo_marcacion
        assert_equal REGISTRO_ID, result.id

        assert_enqueued_with(
          job: SendPushNotificationJob,
          args: [result.empleado_id, result.id],
          queue: "push_notifications"
        )
      end
    end
  end
end
