# frozen_string_literal: true

module Serializer
  module AlertaAusenciaSerializer
    def self.as_json(alerta_hash)
      return nil if alerta_hash.nil?

      {
        id: alerta_hash[:id],
        empleadoId: alerta_hash[:empleado_id],
        empleadoNombre: alerta_hash[:empleado_nombre],
        empleadoApellido: alerta_hash[:empleado_apellido],
        obraId: alerta_hash[:obra_id],
        obraNombre: alerta_hash[:obra_nombre],
        fecha: alerta_hash[:fecha],
        estado: alerta_hash[:estado],
        evaluadoEn: alerta_hash[:evaluado_en]
      }
    end

    def self.as_json_collection(alertas)
      alertas.map { |a| as_json(a) }
    end
  end
end
