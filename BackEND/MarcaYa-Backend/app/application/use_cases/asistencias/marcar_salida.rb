# frozen_string_literal: true

module Application
  module UseCases
    module Asistencias
      class MarcarSalida
        def initialize(asistencia_repo:, gps_service:)
          @asistencia_repo = asistencia_repo
          @gps_service = gps_service
        end

        def ejecutar(empleado_id:, parada_id:, latitud:, longitud:,
                     is_mocked: false, fecha_hora: nil, cliente_marcacion_id: nil)
          # Buscar entrada activa
          entrada = @asistencia_repo.buscar_entrada_activa(empleado_id)
          unless entrada
            raise Domain::Errors::AsistenciaNoEncontradaError,
              "No se encontró entrada activa para el empleado ##{empleado_id}"
          end

          # Validar GPS (opcional — registra pero no bloquea)
          coordenada = Domain::ValueObjects::CoordenadaGps.new(latitud: latitud, longitud: longitud)
          # Usar la parada del registro de entrada para validar
          centro = Domain::ValueObjects::CoordenadaGps.new(
            latitud: entrada.latitud_registrada,
            longitud: entrada.longitud_registrada
          )
          # Obtener radio de la parada del registro de entrada
          valida_gps = is_mocked ? false : true
          observaciones_finales = is_mocked ? "Fake GPS Detectado" : nil

          # Calcular duración de jornada en minutos
          ahora = fecha_hora || Time.now
          duracion_jornada = ((ahora - entrada.fecha_hora) / 60).to_i
          duracion_jornada = [duracion_jornada, 1].max # Mínimo 1 minuto

          # Crear registro de salida
          registro = Domain::Entities::RegistroAsistencia.new(
            id: nil,
            empleado_id: empleado_id,
            parada_id: parada_id,
            tipo_marcacion: Domain::ValueObjects::TipoMarcacion::SALIDA,
            fecha_hora: ahora,
            latitud_registrada: latitud,
            longitud_registrada: longitud,
            valida_gps: valida_gps,
            duracion_jornada: duracion_jornada,
            observaciones: observaciones_finales,
            cliente_marcacion_id: cliente_marcacion_id
          )

          registro.validar!
          @asistencia_repo.guardar(registro)
        end
      end
    end
  end
end
