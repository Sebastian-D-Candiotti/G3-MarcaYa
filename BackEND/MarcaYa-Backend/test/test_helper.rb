ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # Disabled for Phase 7 to avoid PG deadlocks with fixture-heavy integration tests
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Generates a valid JWT token for the given usuario fixture and sets the
    # Authorization header on subsequent requests.
    def authenticate_as(fixture_label)
      user = usuarios(fixture_label)
      @authenticated_token = Infrastructure::Services::JwtTokenService.encode(
        "user_id" => user.id,
        "rol" => user.rol
      )
    end

    # Override common HTTP verbs to include auth header automatically when set
    def get(path, **options)
      options[:headers] = merge_auth_header(options[:headers])
      super(path, **options)
    end

    def post(path, **options)
      options[:headers] = merge_auth_header(options[:headers])
      super(path, **options)
    end

    def put(path, **options)
      options[:headers] = merge_auth_header(options[:headers])
      super(path, **options)
    end

    def patch(path, **options)
      options[:headers] = merge_auth_header(options[:headers])
      super(path, **options)
    end

    def delete(path, **options)
      options[:headers] = merge_auth_header(options[:headers])
      super(path, **options)
    end

    private

    def merge_auth_header(existing)
      return existing unless @authenticated_token

      headers = existing || {}
      headers.merge("Authorization" => "Bearer #{@authenticated_token}")
    end
  end
end
