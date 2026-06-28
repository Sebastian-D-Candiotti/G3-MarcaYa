# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarAsistencia
    class AsistenciaFacade
      def initialize(asistencia_repo:, empleado_repo:, parada_repo:, empleado_parada_repo:, gps_service:)
        @asistencia_repo = asistencia_repo
        @empleado_repo = empleado_repo
        @parada_repo = parada_repo
        @empleado_parada_repo = empleado_parada_repo
        @gps_service = gps_service
      end

      def marcar_entrada(empleado_id:, parada_id:, latitud:, longitud:, is_mocked: false)
        UseCases::Asistencias::MarcarEntrada.new(
          asistencia_repo: @asistencia_repo,
          empleado_repo: @empleado_repo,
          parada_repo: @parada_repo,
          empleado_parada_repo: @empleado_parada_repo,
          gps_service: @gps_service
        ).ejecutar(empleado_id: empleado_id, parada_id: parada_id, latitud: latitud, longitud: longitud, is_mocked: is_mocked)
      end

      def marcar_salida(empleado_id:, parada_id:, latitud:, longitud:, is_mocked: false)
        UseCases::Asistencias::MarcarSalida.new(
          asistencia_repo: @asistencia_repo,
          gps_service: @gps_service
        ).ejecutar(empleado_id: empleado_id, parada_id: parada_id, latitud: latitud, longitud: longitud, is_mocked: is_mocked)
      end

      def historial_personal(empleado_id:)
        UseCases::Asistencias::HistorialPersonal.new(
          asistencia_repo: @asistencia_repo
        ).ejecutar(empleado_id: empleado_id)
      end

      def historial_empleado(empleado_id:)
        UseCases::Asistencias::HistorialEmpleado.new(
          asistencia_repo: @asistencia_repo
        ).ejecutar(empleado_id: empleado_id)
      end

      def tiempo_real(parada_id: nil)
        UseCases::Asistencias::TiempoReal.new(
          asistencia_repo: @asistencia_repo
        ).ejecutar(parada_id: parada_id)
      end
    end
  end
end
