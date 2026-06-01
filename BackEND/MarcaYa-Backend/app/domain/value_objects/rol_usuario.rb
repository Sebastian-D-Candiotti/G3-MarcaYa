# frozen_string_literal: true

module Domain
  module ValueObjects
    class RolUsuario
      EMPLEADO = "empleado"
      EMPRESA = "empresa"
      ADMIN = "admin"

      VALIDOS = [EMPLEADO, EMPRESA, ADMIN].freeze

      attr_reader :valor

      def initialize(valor)
        @valor = valor.to_s.downcase
        raise ArgumentError, "Rol inválido: #{valor}" unless VALIDOS.include?(@valor)
      end

      def empleado? = @valor == EMPLEADO
      def empresa? = @valor == EMPRESA
      def admin? = @valor == ADMIN

      def ==(other)
        return @valor == other.to_s unless other.is_a?(RolUsuario)

        @valor == other.valor
      end

      def to_s = @valor
    end
  end
end
