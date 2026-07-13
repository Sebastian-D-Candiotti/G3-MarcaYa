# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/infrastructure/services/verification_code_service"

class VerificationCodeServiceTest < Minitest::Test
  Service = Infrastructure::Services::VerificationCodeService

  def test_generate_returns_exactly_six_numeric_digits
    50.times do
      assert_match(/\A\d{6}\z/, Service.generate)
    end
  end

  def test_generate_preserves_leading_zeroes
    assert_equal "004281", Service.generate(random_number: 4_281)
  end

  def test_expires_at_adds_exactly_ten_minutes
    now = Time.utc(2026, 7, 12, 10, 0, 0)

    assert_equal now + 600, Service.expires_at(now: now)
  end

  def test_digest_does_not_store_plain_code_and_matches_original
    digest = Service.digest("004281")

    refute_equal "004281", digest.to_s
    assert Service.matches?("004281", digest)
    refute Service.matches?("004282", digest)
  end

  def test_matches_returns_false_for_invalid_hash
    refute Service.matches?("123456", "not-a-bcrypt-hash")
  end
end
