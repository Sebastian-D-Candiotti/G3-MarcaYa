# frozen_string_literal: true

module Domain
  module ValueObjects
    class EstadoSolicitud
      PENDIENTE = "pendiente"
      ACEPTADA = "aceptada"
      RECHAZADA = "rechazada"

      VALIDOS = [PENDIENTE, ACEPTADA, RECHAZADA].freeze

      attr_reader :valor

      def initialize(valor)
        @valor = valor.to_s.downcase
        raise ArgumentError, "Estado de solicitud inválido: #{valor}" unless VALIDOS.include?(@valor)
      end

      def pendiente? = @valor == PENDIENTE
      def aceptada? = @valor == ACEPTADA
      def rechazada? = @valor == RECHAZADA

      def ==(other)
        return @valor == other.to_s unless other.is_a?(EstadoSolicitud)

        @valor == other.valor
      end

      def to_s = @valor
    end
  end
end
