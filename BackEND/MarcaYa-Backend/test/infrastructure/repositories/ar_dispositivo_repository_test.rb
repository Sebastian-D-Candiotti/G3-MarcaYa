# frozen_string_literal: true

require "test_helper"
require_relative "../../../app/domain/errors"
require_relative "../../../app/infrastructure/orm/device_record"
require_relative "../../../app/infrastructure/repositories/ar_dispositivo_repository"

class Infrastructure::Repositories::ArDispositivoRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArDispositivoRepository.new
    @user = usuarios(:empresa_activa)
  end

  # --- crear_o_actualizar ---

  test "crear_o_actualizar creates a new device record" do
    record = @repository.crear_o_actualizar(
      user_id: @user.id,
      fcm_token: "fcm_token_abc_123",
      platform: "android"
    )

    assert_instance_of Infrastructure::Orm::DeviceRecord, record
    assert_equal "fcm_token_abc_123", record.fcm_token
    assert_equal "android", record.platform
    assert_equal @user.id, record.user_id
    assert record.persisted?
  end

  test "crear_o_actualizar updates platform for existing token" do
    @repository.crear_o_actualizar(
      user_id: @user.id, fcm_token: "fcm_token_update", platform: "android"
    )

    updated = @repository.crear_o_actualizar(
      user_id: @user.id, fcm_token: "fcm_token_update", platform: "ios"
    )

    assert_equal "ios", updated.platform
    assert_equal "fcm_token_update", updated.fcm_token
  end

  test "crear_o_actualizar creates new record for different token same user" do
    record1 = @repository.crear_o_actualizar(
      user_id: @user.id, fcm_token: "token_multi_1", platform: "android"
    )
    record2 = @repository.crear_o_actualizar(
      user_id: @user.id, fcm_token: "token_multi_2", platform: "ios"
    )

    refute_equal record1.id, record2.id
    assert_equal 2, Infrastructure::Orm::DeviceRecord.where(user_id: @user.id).count
  end

  # --- activos_por_empleado ---

  test "activos_por_empleado returns devices for user" do
    @repository.crear_o_actualizar(user_id: @user.id, fcm_token: "token_act_1", platform: "android")
    @repository.crear_o_actualizar(user_id: @user.id, fcm_token: "token_act_2", platform: "ios")

    devices = @repository.activos_por_empleado(@user.id)

    assert_equal 2, devices.length
    assert devices.all? { |d| d.is_a?(Infrastructure::Orm::DeviceRecord) }
  end

  test "activos_por_empleado returns empty array for user without devices" do
    devices = @repository.activos_por_empleado(999_999)
    assert_equal [], devices
  end

  test "activos_por_empleado only returns devices for specified user" do
    other_user = usuarios(:empleado_activo)
    @repository.crear_o_actualizar(user_id: @user.id, fcm_token: "user_a_token", platform: "android")
    @repository.crear_o_actualizar(user_id: other_user.id, fcm_token: "user_b_token", platform: "ios")

    result = @repository.activos_por_empleado(@user.id)

    assert_equal 1, result.length
    assert_equal "user_a_token", result.first.fcm_token
  end
end
