# frozen_string_literal: true

module Serializer
  module ValoracionSerializer
    def self.as_json(valoracion)
      return nil if valoracion.nil?

      {
        id: valoracion.id,
        empleadoId: valoracion.empleado_id,
        empresaId: valoracion.empresa_id,
        puntuacion: valoracion.puntuacion,
        comentario: valoracion.comentario,
        createdAt: valoracion.created_at
      }
    end
  end
end
