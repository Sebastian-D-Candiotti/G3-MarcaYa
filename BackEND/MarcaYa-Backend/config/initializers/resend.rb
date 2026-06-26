# frozen_string_literal: true

# Resend email configuration
# API key stored in Rails credentials under resend.api_key

Resend.api_key = ENV["RESEND_API_KEY"] || Rails.application.credentials.dig(:resend, :api_key)
