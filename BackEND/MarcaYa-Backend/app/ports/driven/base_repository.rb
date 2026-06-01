# frozen_string_literal: true

module Ports
  module Driven
    module BaseRepository
      # Raises a StandardError with a standardized "not found" message.
      #
      # @param id [Integer, String] The ID of the entity
      # @param entity_name [String] The name of the entity type
      # @raise [StandardError] Always raises with a descriptive message
      def self.not_found!(id, entity_name)
        raise StandardError, "#{entity_name} con id #{id} no encontrado"
      end
    end
  end
end
