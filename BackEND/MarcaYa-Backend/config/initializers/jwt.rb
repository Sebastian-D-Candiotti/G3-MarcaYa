# JWT configuration
# Uses Rails.application.secret_key_base as the HMAC secret
# No additional configuration needed — secret is derived from Rails credentials

module Jwt
  SECRET = Rails.application.secret_key_base
  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  def self.encode(payload, exp = EXPIRY.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: ALGORITHM).first
  end
end
