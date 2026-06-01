# frozen_string_literal: true

require "jwt"

module Infrastructure
  module Services
    class JwtTokenService
      # Encodes a payload hash into a JWT token string.
      # Uses the application's JWT secret and algorithm from the Jwt initializer.
      #
      # @param payload [Hash] The data to encode (e.g., { "user_id" => 1, "rol" => "empresa" })
      # @return [String] The encoded JWT token
      def self.encode(payload)
        exp = Jwt::EXPIRY.from_now.to_i
        JWT.encode(payload.merge(exp: exp), Jwt::SECRET, Jwt::ALGORITHM)
      end

      # Decodes a JWT token string into the original payload hash.
      #
      # @param token [String] The JWT token to decode
      # @return [Hash] The decoded payload
      # @raise [JWT::DecodeError] If the token is invalid or expired
      def self.decode(token)
        JWT.decode(token, Jwt::SECRET, true, algorithm: Jwt::ALGORITHM).first
      end
    end
  end
end
