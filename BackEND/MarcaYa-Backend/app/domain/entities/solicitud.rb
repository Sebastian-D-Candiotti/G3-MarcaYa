# frozen_string_literal: true

require_relative "../value_objects/estado_solicitud"

module Domain
  module Entities
    class Solicitud
      attr_reader :id, :empleado_id, :empresa_id, :estado, :created_at, :updated_at

      def initialize(id:, empleado_id:, empresa_id:,
                     estado: "pendiente", created_at: nil, updated_at: nil)
        @id = id
        @empleado_id = empleado_id
        @empresa_id = empresa_id
        @estado = Domain::ValueObjects::EstadoSolicitud.new(estado)
        @created_at = created_at
        @updated_at = updated_at
      end

      def pendiente? = @estado.pendiente?
      def aceptada? = @estado.aceptada?
      def rechazada? = @estado.rechazada?

      def aceptar!
        raise Domain::Errors::TransicionEstadoInvalidaError unless pendiente?

        @estado = Domain::ValueObjects::EstadoSolicitud.new("aceptada")
      end

      def rechazar!
        raise Domain::Errors::TransicionEstadoInvalidaError unless pendiente?

        @estado = Domain::ValueObjects::EstadoSolicitud.new("rechazada")
      end
    end
  end
end
