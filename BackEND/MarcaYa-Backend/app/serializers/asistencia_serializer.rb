# frozen_string_literal: true

module Serializer
  module AsistenciaSerializer
    def self.as_json(registro)
      return nil if registro.nil?

      {
        id: registro.id,
        empleadoId: registro.empleado_id,
        paradaId: registro.parada_id,
        tipoMarcacion: registro.tipo_marcacion,
        fechaHora: registro.fecha_hora&.iso8601,
        latitudRegistrada: registro.latitud_registrada,
        longitudRegistrada: registro.longitud_registrada,
        clienteMarcacionId: registro.cliente_marcacion_id,
        validaGps: registro.valida_gps,
        duracionJornada: registro.duracion_jornada,
        observaciones: registro.observaciones,
        createdAt: registro.created_at,
        updatedAt: registro.updated_at
      }
    end
  end
end
