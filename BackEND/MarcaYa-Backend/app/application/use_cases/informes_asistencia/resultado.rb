# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class Resultado
        attr_reader :data, :error, :status

        def self.ok(data, status: :ok)
          new(success: true, data: data, status: status)
        end

        def self.fail(error, status: :unprocessable_entity, data: nil)
          new(success: false, error: error, status: status, data: data)
        end

        def initialize(success:, data: nil, error: nil, status: nil)
          @success = success
          @data = data
          @error = error
          @status = status
        end

        def success?
          @success
        end
      end
    end
  end
end
