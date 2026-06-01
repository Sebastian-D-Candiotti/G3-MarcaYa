# frozen_string_literal: true

require "test_helper"
require_relative "../../../app/infrastructure/services/bcrypt_password_service"

class Infrastructure::Services::BcryptPasswordServiceTest < ActiveSupport::TestCase
  test "hash returns a bcrypt hash string" do
    hash = Infrastructure::Services::BcryptPasswordService.hash("mi_clave_secreta")

    assert_kind_of String, hash
    assert hash.start_with?("$2a$"), "BCrypt hash should start with $2a$"
  end

  test "verificar? returns true for matching password" do
    hash = Infrastructure::Services::BcryptPasswordService.hash("mi_clave_secreta")
    assert Infrastructure::Services::BcryptPasswordService.verificar?("mi_clave_secreta", hash)
  end

  test "verificar? returns false for wrong password" do
    hash = Infrastructure::Services::BcryptPasswordService.hash("mi_clave_secreta")
    refute Infrastructure::Services::BcryptPasswordService.verificar?("clave_incorrecta", hash)
  end

  test "hash produces different hashes for same password (unique salts)" do
    hash1 = Infrastructure::Services::BcryptPasswordService.hash("misma_clave")
    hash2 = Infrastructure::Services::BcryptPasswordService.hash("misma_clave")

    assert_not_equal hash1, hash2
    assert Infrastructure::Services::BcryptPasswordService.verificar?("misma_clave", hash1)
    assert Infrastructure::Services::BcryptPasswordService.verificar?("misma_clave", hash2)
  end

  test "verificar? handles plain text legacy passwords" do
    # Simulate a legacy plain-text password stored in clave_hash
    assert Infrastructure::Services::BcryptPasswordService.verificar?("plaintext123", "plaintext123")
  end

  test "verificar? returns false for nil password" do
    hash = Infrastructure::Services::BcryptPasswordService.hash("real_password")
    refute Infrastructure::Services::BcryptPasswordService.verificar?(nil, hash)
  end
end
