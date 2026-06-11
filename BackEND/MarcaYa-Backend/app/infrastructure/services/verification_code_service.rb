# frozen_string_literal: true

require "bcrypt"
require "securerandom"

module Infrastructure
  module Services
    class VerificationCodeService
      CODE_TTL_SECONDS = 10 * 60

      def self.generate
        SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")
      end

      def self.digest(code)
        BCrypt::Password.create(code.to_s)
      end

      def self.matches?(code, digest)
        return false if code.nil? || digest.nil?

        BCrypt::Password.new(digest) == code.to_s
      rescue BCrypt::Errors::InvalidHash
        false
      end

      def self.expires_at(now: current_time)
        now + CODE_TTL_SECONDS
      end

      def self.current_time
        Time.respond_to?(:current) ? Time.current : Time.now
      end
    end
  end
end
