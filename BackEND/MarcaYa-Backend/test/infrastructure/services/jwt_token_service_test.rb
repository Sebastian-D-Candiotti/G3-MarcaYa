# frozen_string_literal: true

require "test_helper"
require_relative "../../../app/infrastructure/services/jwt_token_service"

class Infrastructure::Services::JwtTokenServiceTest < ActiveSupport::TestCase
  test "encode returns a JWT string" do
    payload = { "user_id" => 1, "rol" => "empresa" }
    token = Infrastructure::Services::JwtTokenService.encode(payload)

    assert_instance_of String, token
    assert token.split(".").length == 3, "JWT should have 3 segments"
  end

  test "decode returns original payload" do
    payload = { "user_id" => 42, "rol" => "empleado" }
    token = Infrastructure::Services::JwtTokenService.encode(payload)
    decoded = Infrastructure::Services::JwtTokenService.decode(token)

    assert_equal 42, decoded["user_id"]
    assert_equal "empleado", decoded["rol"]
  end

  test "encode and decode preserves multiple fields" do
    payload = { "user_id" => 7, "rol" => "admin", "correo" => "admin@test.com" }
    token = Infrastructure::Services::JwtTokenService.encode(payload)
    decoded = Infrastructure::Services::JwtTokenService.decode(token)

    assert_equal 7, decoded["user_id"]
    assert_equal "admin", decoded["rol"]
    assert_equal "admin@test.com", decoded["correo"]
  end

  test "decode raises JWT::DecodeError for invalid token" do
    assert_raises JWT::DecodeError do
      Infrastructure::Services::JwtTokenService.decode("invalid.token.here")
    end
  end

  test "decode raises JWT::ExpiredSignature for expired token" do
    payload = { "user_id" => 1 }
    token = JWT.encode(payload.merge(exp: 1.minute.ago.to_i), Jwt::SECRET, Jwt::ALGORITHM)

    assert_raises JWT::ExpiredSignature do
      Infrastructure::Services::JwtTokenService.decode(token)
    end
  end
end
