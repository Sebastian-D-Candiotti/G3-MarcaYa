# frozen_string_literal: true

module Domain
  module ValueObjects
    class TipoMarcacion
      ENTRADA = "ENTRADA"
      SALIDA = "SALIDA"

      VALIDOS = [ENTRADA, SALIDA].freeze

      attr_reader :valor

      def initialize(valor)
        @valor = valor.to_s.upcase
        raise ArgumentError, "Tipo de marcación inválido: #{valor}" unless VALIDOS.include?(@valor)
      end

      def entrada? = @valor == ENTRADA
      def salida? = @valor == SALIDA

      def ==(other)
        return @valor == other.to_s.upcase unless other.is_a?(TipoMarcacion)

        @valor == other.valor
      end

      def to_s = @valor
    end
  end
end
