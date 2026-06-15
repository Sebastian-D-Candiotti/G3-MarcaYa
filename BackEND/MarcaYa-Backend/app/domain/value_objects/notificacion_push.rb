# frozen_string_literal: true

module Domain
  module ValueObjects
    # Immutable value object representing a push notification payload.
    # Validates that title, body, and data payload are present and well-formed.
    class NotificacionPush
      attr_reader :title, :body, :data

      def initialize(title:, body:, data:)
        @title = title
        @body = body
        @data = data
        validate!
      end

      def to_h
        { title: title, body: body, data: data }
      end

      private

      def validate!
        raise Domain::Errors::ValidacionError, "title es requerido" if title.nil? || title.strip.empty?
        raise Domain::Errors::ValidacionError, "body es requerido" if body.nil? || body.strip.empty?
        unless data.is_a?(Hash) && data[:type] && data[:screen] && data[:marcacion_id]
          raise Domain::Errors::ValidacionError, "data debe incluir :type, :screen, :marcacion_id"
        end
      end
    end
  end
end
