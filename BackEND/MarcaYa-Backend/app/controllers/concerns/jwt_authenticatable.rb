# frozen_string_literal: true

# JWT Authentication concern for API controllers.
#
# Provides:
#   - authenticate! before_action for protected endpoints
#   - current_user helper method
#
# Designed to be included in BaseController. Auth endpoints (login, registro)
# should skip this filter using skip_before_action.
#
# Phase 4 refactoring: this will delegate to Infrastructure::Services::JwtTokenService
# and Infrastructure::Orm::UsuarioRecord when those exist.

module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate! if respond_to?(:before_action)
  end

  private

  def authenticate!
    token = extract_token
    raise JWT::DecodeError, "Missing token" unless token

    payload = Infrastructure::Services::JwtTokenService.decode(token)
    @current_user = Infrastructure::Orm::UsuarioRecord.find(payload["user_id"])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: "No autorizado" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token
    header = request.headers["Authorization"]
    header&.split(" ")&.last
  end
end
