# frozen_string_literal: true

module Serializer
  module SolicitudSerializer
    def self.as_json(solicitud)
      return nil if solicitud.nil?

      {
        id: solicitud.id,
        empleadoId: solicitud.empleado_id,
        empresaId: solicitud.empresa_id,
        estado: solicitud.estado.to_s,
        createdAt: solicitud.created_at
      }
    end
  end
end
