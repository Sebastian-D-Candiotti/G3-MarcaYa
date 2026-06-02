# frozen_string_literal: true

module Domain
  module Entities
    class Parada
      attr_reader :id, :obra_id, :nombre, :latitud, :longitud, :radio_metros, :estado, :created_at, :updated_at

      def initialize(id:, obra_id:, nombre:, latitud:, longitud:, radio_metros: 50, estado: "activa", created_at: nil, updated_at: nil)
        @id = id
        @obra_id = obra_id
        @nombre = nombre
        @latitud = latitud
        @longitud = longitud
        @radio_metros = radio_metros
        @estado = estado
        @created_at = created_at
        @updated_at = updated_at
      end

      def activa?
        @estado == "activa"
      end

      # Valida las restricciones físicas y lógicas del dominio
      def validar!
        raise Domain::Errors::ValidacionError, "El nombre de la parada es obligatorio" if @nombre.nil? || @nombre.to_s.strip.empty?
        raise Domain::Errors::ValidacionError, "La obra asociada es obligatoria" if @obra_id.nil?
        raise Domain::Errors::ValidacionError, "La latitud debe estar en el rango [-90.0, 90.0]" unless @latitud.is_a?(Numeric) && @latitud.between?(-90.0, 90.0)
        raise Domain::Errors::ValidacionError, "La longitud debe estar en el rango [-180.0, 180.0]" unless @longitud.is_a?(Numeric) && @longitud.between?(-180.0, 180.0)
        raise Domain::Errors::ValidacionError, "El radio debe ser un entero mayor a cero" unless @radio_metros.is_a?(Integer) && @radio_metros > 0
        raise Domain::Errors::ValidacionError, "El estado debe ser 'activa' o 'inactiva'" unless %w[activa inactiva].include?(@estado)
      end
    end
  end
end
