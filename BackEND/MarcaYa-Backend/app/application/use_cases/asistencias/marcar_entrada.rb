# frozen_string_literal: true

module Application
  module UseCases
    module Asistencias
      class MarcarEntrada
        def initialize(asistencia_repo:, empleado_repo:, parada_repo:, empleado_parada_repo:, gps_service:)
          @asistencia_repo = asistencia_repo
          @empleado_repo = empleado_repo
          @parada_repo = parada_repo
          @empleado_parada_repo = empleado_parada_repo
          @gps_service = gps_service
        end

        def ejecutar(empleado_id:, parada_id:, latitud:, longitud:,
                     fecha_hora: nil, cliente_marcacion_id: nil)
          # Validar que el empleado exista
          @empleado_repo.find_by_id!(empleado_id)

          # Validar que la parada exista
          parada = @parada_repo.find_by_id!(parada_id)

          # Validar que la parada esté activa
          unless parada.activa?
            raise Domain::Errors::ParadaInactivaError, "La parada ##{parada_id} no está activa"
          end

          # Validar que el empleado esté asignado a la parada y activo
          asignacion = @empleado_parada_repo.buscar_asignacion(empleado_id, parada_id)
          unless asignacion && asignacion.activo?
            raise Domain::Errors::EmpleadoNoAsignadoParadaError,
              "El empleado ##{empleado_id} no está asignado activamente a la parada ##{parada_id}"
          end

          # Validar que no exista una entrada activa
          entrada_activa = @asistencia_repo.buscar_entrada_activa(empleado_id)
          if entrada_activa
            raise Domain::Errors::EntradaActivaExistenteError,
              "El empleado ##{empleado_id} ya tiene una entrada activa registrada"
          end

          # Validar GPS
          coordenada = Domain::ValueObjects::CoordenadaGps.new(latitud: latitud, longitud: longitud)
          centro = Domain::ValueObjects::CoordenadaGps.new(latitud: parada.latitud, longitud: parada.longitud)
          valida_gps = @gps_service.dentro_de_geocerca?(coordenada, centro, parada.radio_metros)
          observaciones = valida_gps ? nil : "Fuera de zona"
          fecha_registro = fecha_hora || Time.now

          # Crear y persistir el registro
          registro = Domain::Entities::RegistroAsistencia.new(
            id: nil,
            empleado_id: empleado_id,
            parada_id: parada_id,
            tipo_marcacion: Domain::ValueObjects::TipoMarcacion::ENTRADA,
            fecha_hora: fecha_registro,
            latitud_registrada: latitud,
            longitud_registrada: longitud,
            valida_gps: valida_gps,
            duracion_jornada: nil,
            observaciones: observaciones,
            cliente_marcacion_id: cliente_marcacion_id
          )

          registro.validar!
          @asistencia_repo.guardar(registro)
        end
      end
    end
  end
end
