# frozen_string_literal: true

module Domain
  module Services
    class ValoracionPromedioService
      def self.calcular(valoraciones)
        raise ArgumentError, "No hay valoraciones para calcular promedio" if valoraciones.empty?

        total = valoraciones.sum(&:puntuacion)
        (total.to_f / valoraciones.length).round(1)
      end
    end
  end
end
