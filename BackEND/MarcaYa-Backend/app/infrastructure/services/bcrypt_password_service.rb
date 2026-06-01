# frozen_string_literal: true

require "bcrypt"

module Infrastructure
  module Services
    class BcryptPasswordService
      # Hashes a plain-text password using BCrypt.
      #
      # @param clave [String] The plain-text password
      # @return [String] The BCrypt hash
      def self.hash(clave)
        BCrypt::Password.create(clave)
      end

      # Verifies a password against a stored hash.
      # Supports both BCrypt hashes and legacy plain-text passwords.
      #
      # @param clave [String] The plain-text password to verify
      # @param hash_almacenado [String] The stored hash (BCrypt hash or legacy plain text)
      # @return [Boolean] true if the password matches
      def self.verificar?(clave, hash_almacenado)
        return false if clave.nil? || hash_almacenado.nil?

        bcrypt = BCrypt::Password.new(hash_almacenado)
        bcrypt == clave
      rescue BCrypt::Errors::InvalidHash
        # Fallback: legacy plain-text comparison
        clave == hash_almacenado
      end
    end
  end
end
