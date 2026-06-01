# JWT configuration
# Uses Rails.application.secret_key_base as the HMAC secret
# No additional configuration needed — secret is derived from Rails credentials

module Jwt
  SECRET = Rails.application.secret_key_base
  ALGORITHM = "HS256"
  EXPIRY = 24.hours
end
