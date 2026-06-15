# frozen_string_literal: true

module Api
  module V1
    # Handles FCM device token registration and updates.
    # All endpoints require authentication via JwtAuthenticatable.
    class DispositivosController < BaseController
      def registrar
        dispositivo_repo = Rails.configuration.di.repos[:dispositivo]

        record = dispositivo_repo.crear_o_actualizar(
          user_id: current_user.id,
          fcm_token: params[:fcm_token],
          platform: params[:platform] || "android"
        )

        is_new = record.previous_changes.key?("id")

        render json: {
          mensaje: is_new ? "Dispositivo registrado" : "Dispositivo actualizado",
          fcm_token: record.fcm_token,
          platform: record.platform
        }, status: is_new ? :created : :ok
      end
    end
  end
end
