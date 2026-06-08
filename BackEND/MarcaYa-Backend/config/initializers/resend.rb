# frozen_string_literal: true

# Resend email configuration
# API key stored in Rails credentials under resend.api_key

Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)
