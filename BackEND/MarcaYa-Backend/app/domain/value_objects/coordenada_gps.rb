# frozen_string_literal: true

module Domain
  module ValueObjects
    class CoordenadaGps
      attr_reader :latitud, :longitud

      def initialize(latitud:, longitud:)
        @latitud = latitud
        @longitud = longitud
        validate!
      end

      def ==(other)
        return false unless other.is_a?(CoordenadaGps)

        latitud == other.latitud && longitud == other.longitud
      end

      alias eql? ==

      def to_s
        "(#{latitud}, #{longitud})"
      end

      private

      def validate!
        raise ArgumentError, "Latitud debe estar entre -90 y 90" unless latitud >= -90 && latitud <= 90
        raise ArgumentError, "Longitud debe estar entre -180 y 180" unless longitud >= -180 && longitud <= 180
      end
    end
  end
end
