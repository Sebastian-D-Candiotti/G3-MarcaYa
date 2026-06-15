# frozen_string_literal: true

module Infrastructure
  module Repositories
    # Implements Ports::Driven::IDispositivoRepository using ActiveRecord.
    # Supports multiple devices per user (different tokens = different devices).
    # Uniqueness is enforced at the fcm_token level — the same token always
    # updates the same record (handles Apple token rotation).
    class ArDispositivoRepository
      def activos_por_empleado(empleado_id)
        ::Infrastructure::Orm::DeviceRecord.where(user_id: empleado_id).to_a
      end

      def crear_o_actualizar(user_id:, fcm_token:, platform:)
        record = ::Infrastructure::Orm::DeviceRecord.find_or_initialize_by(fcm_token: fcm_token)
        record.user_id = user_id
        record.platform = platform
        record.save!
        record
      end
    end
  end
end
