# frozen_string_literal: true

module Domain
  module Entities
    class Valoracion
      attr_reader :id, :empleado_id, :empresa_id, :puntuacion, :comentario,
                  :created_at

      def initialize(id:, empleado_id:, empresa_id:, puntuacion:,
                     comentario: nil, created_at: nil)
        @id = id
        @empleado_id = empleado_id
        @empresa_id = empresa_id
        @puntuacion = puntuacion
        @comentario = comentario
        @created_at = created_at
        validar_puntuacion!
      end

      def validar_puntuacion!
        return if @puntuacion.is_a?(Integer) && @puntuacion >= 1 && @puntuacion <= 5

        raise Domain::Errors::PuntuacionInvalidaError,
              "Puntuación debe ser un entero entre 1 y 5"
      end
    end
  end
end
