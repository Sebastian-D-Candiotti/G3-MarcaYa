# frozen_string_literal: true

module Domain
  module Entities
    class RegistroAsistencia
      attr_reader :id, :empleado_id, :parada_id, :tipo_marcacion, :fecha_hora,
                  :latitud_registrada, :longitud_registrada, :valida_gps,
                  :duracion_jornada, :observaciones, :cliente_marcacion_id,
                  :created_at, :updated_at

      def initialize(id:, empleado_id:, parada_id:, tipo_marcacion:, fecha_hora:,
                     latitud_registrada:, longitud_registrada:, valida_gps: true,
                     duracion_jornada: nil, observaciones: nil,
                     cliente_marcacion_id: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @empleado_id = empleado_id
        @parada_id = parada_id
        @tipo_marcacion = tipo_marcacion
        @fecha_hora = fecha_hora
        @latitud_registrada = latitud_registrada
        @longitud_registrada = longitud_registrada
        @valida_gps = valida_gps
        @duracion_jornada = duracion_jornada
        @observaciones = observaciones
        @cliente_marcacion_id = cliente_marcacion_id
        @created_at = created_at
        @updated_at = updated_at
      end

      def entrada?
        @tipo_marcacion == "ENTRADA"
      end

      def salida?
        @tipo_marcacion == "SALIDA"
      end

      def validar!
        raise Domain::Errors::ValidacionError, "El empleado es obligatorio" if @empleado_id.nil?
        raise Domain::Errors::ValidacionError, "La parada es obligatoria" if @parada_id.nil?
        raise Domain::Errors::ValidacionError, "El tipo de marcación debe ser ENTRADA o SALIDA" unless %w[ENTRADA SALIDA].include?(@tipo_marcacion)
        raise Domain::Errors::ValidacionError, "La fecha y hora es obligatoria" if @fecha_hora.nil?
        raise Domain::Errors::ValidacionError, "La latitud debe estar en el rango [-90.0, 90.0]" unless @latitud_registrada.is_a?(Numeric) && @latitud_registrada.between?(-90.0, 90.0)
        raise Domain::Errors::ValidacionError, "La longitud debe estar en el rango [-180.0, 180.0]" unless @longitud_registrada.is_a?(Numeric) && @longitud_registrada.between?(-180.0, 180.0)

        if entrada? && !@duracion_jornada.nil?
          raise Domain::Errors::ValidacionError, "La duración de jornada debe ser nil para ENTRADA"
        end

        if salida?
          raise Domain::Errors::ValidacionError, "La duración de jornada es obligatoria para SALIDA" if @duracion_jornada.nil?
          raise Domain::Errors::ValidacionError, "La duración de jornada debe ser un entero positivo" unless @duracion_jornada.is_a?(Integer) && @duracion_jornada.positive?
        end
      end
    end
  end
end
