# frozen_string_literal: true

require "time"

module Application
  module UseCases
    module Asistencias
      class SincronizarMarcacionesOffline
        def initialize(asistencia_repo:, empleado_repo:, parada_repo:, empleado_parada_repo:, gps_service:)
          @asistencia_repo = asistencia_repo
          @empleado_repo = empleado_repo
          @parada_repo = parada_repo
          @empleado_parada_repo = empleado_parada_repo
          @gps_service = gps_service
        end

        def ejecutar(empleado_id:, marcaciones:)
          @empleado_repo.find_by_id!(empleado_id)

          resultado = { sincronizados: [], duplicados: [], fallidos: [] }

          Array(marcaciones).each_with_index do |raw_marcacion, index|
            marcacion = normalizar(raw_marcacion)
            cliente_id = valor(marcacion, :cliente_marcacion_id, :clienteId)

            if cliente_id.to_s.strip.empty?
              agregar_fallido(resultado, index, cliente_id, "cliente_marcacion_id es obligatorio")
              next
            end

            duplicado = @asistencia_repo.find_by_cliente_marcacion_id(cliente_id)
            if duplicado
              resultado[:duplicados] << respuesta_registro(duplicado, cliente_id, index)
              next
            end

            registro = crear_registro!(empleado_id, marcacion, cliente_id)
            resultado[:sincronizados] << respuesta_registro(registro, cliente_id, index)
          rescue Domain::Errors::ValidacionError,
                 Domain::Errors::AsistenciaNoEncontradaError,
                 Domain::Errors::ParadaNoEncontradaError,
                 Domain::Errors::EmpleadoNoAsignadoParadaError,
                 Domain::Errors::ParadaInactivaError,
                 Domain::Errors::EntradaActivaExistenteError => e
            agregar_fallido(resultado, index, cliente_id, e.message)
          rescue StandardError => e
            agregar_fallido(resultado, index, cliente_id, e.message)
          end

          resultado
        end

        private

        def crear_registro!(empleado_id, marcacion, cliente_id)
          tipo = valor(marcacion, :tipo_marcacion, :tipoMarcacion).to_s.upcase
          parada_id = Integer(valor(marcacion, :parada_id, :paradaId))
          latitud = Float(valor(marcacion, :latitud, :latitud_registrada, :latitudRegistrada))
          longitud = Float(valor(marcacion, :longitud, :longitud_registrada, :longitudRegistrada))
          fecha_hora = parse_fecha!(valor(
                                      marcacion,
                                      :fecha_hora_original,
                                      :fechaHoraOriginal,
                                      :marcada_en,
                                      :marcadaEn
                                    ))

          case tipo
          when "ENTRADA"
            marcar_entrada.ejecutar(
              empleado_id: empleado_id,
              parada_id: parada_id,
              latitud: latitud,
              longitud: longitud,
              fecha_hora: fecha_hora,
              cliente_marcacion_id: cliente_id
            )
          when "SALIDA"
            marcar_salida.ejecutar(
              empleado_id: empleado_id,
              parada_id: parada_id,
              latitud: latitud,
              longitud: longitud,
              fecha_hora: fecha_hora,
              cliente_marcacion_id: cliente_id
            )
          else
            raise Domain::Errors::ValidacionError, "tipo_marcacion debe ser ENTRADA o SALIDA"
          end
        end

        def marcar_entrada
          @marcar_entrada ||= MarcarEntrada.new(
            asistencia_repo: @asistencia_repo,
            empleado_repo: @empleado_repo,
            parada_repo: @parada_repo,
            empleado_parada_repo: @empleado_parada_repo,
            gps_service: @gps_service
          )
        end

        def marcar_salida
          @marcar_salida ||= MarcarSalida.new(
            asistencia_repo: @asistencia_repo,
            gps_service: @gps_service
          )
        end

        def normalizar(raw_marcacion)
          hash = raw_marcacion.respond_to?(:to_unsafe_h) ? raw_marcacion.to_unsafe_h : raw_marcacion
          return hash unless hash.respond_to?(:each_with_object)

          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def valor(hash, *keys)
          keys.each do |key|
            return hash[key] if hash.respond_to?(:key?) && hash.key?(key)
            string_key = key.to_s
            return hash[string_key] if hash.respond_to?(:key?) && hash.key?(string_key)
          end
          nil
        end

        def parse_fecha!(value)
          raise Domain::Errors::ValidacionError, "fecha_hora_original es obligatoria" if value.to_s.strip.empty?

          Time.iso8601(value.to_s)
        rescue ArgumentError
          raise Domain::Errors::ValidacionError, "fecha_hora_original no tiene formato ISO8601 valido"
        end

        def respuesta_registro(registro, cliente_id, index)
          {
            index: index,
            cliente_marcacion_id: cliente_id,
            id: registro.id,
            tipo_marcacion: registro.tipo_marcacion,
            fecha_hora: registro.fecha_hora&.iso8601
          }
        end

        def agregar_fallido(resultado, index, cliente_id, error)
          resultado[:fallidos] << {
            index: index,
            cliente_marcacion_id: cliente_id,
            error: error
          }
        end
      end
    end
  end
end
