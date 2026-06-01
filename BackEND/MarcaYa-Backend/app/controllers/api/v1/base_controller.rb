# frozen_string_literal: true

module Api
  module V1
    # Base controller for all API v1 endpoints.
    #
    # Includes JwtAuthenticatable which adds before_action :authenticate!
    # for all endpoints except login and registro.
    #
    # Phase 7 refactoring: all existing controllers will be updated to
    # inherit from this class instead of ApplicationController.
    class BaseController < ApplicationController
      include JwtAuthenticatable
    end
  end
end
