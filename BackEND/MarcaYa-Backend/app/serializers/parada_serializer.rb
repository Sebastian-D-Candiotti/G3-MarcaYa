# frozen_string_literal: true

module Serializer
  module ParadaSerializer
    def self.as_json(parada)
      return nil if parada.nil?

      {
        id: parada.id,
        obraId: parada.obra_id,
        nombre: parada.nombre,
        latitud: parada.latitud,
        longitud: parada.longitud,
        radioMetros: parada.radio_metros,
        estado: parada.estado,
        createdAt: parada.created_at,
        updatedAt: parada.updated_at
      }
    end
  end
end
