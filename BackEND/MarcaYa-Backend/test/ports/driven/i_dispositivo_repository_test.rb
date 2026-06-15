# frozen_string_literal: true

require "test_helper"

class Ports::Driven::IDispositivoRepositoryTest < ActiveSupport::TestCase
  def setup_fixtures; end
  def teardown_fixtures; end

  test "activos_por_empleado raises NotImplementedError" do
    assert_raises(NotImplementedError) { Ports::Driven::IDispositivoRepository.activos_por_empleado(1) }
  end

  test "crear_o_actualizar raises NotImplementedError" do
    assert_raises(NotImplementedError) do
      Ports::Driven::IDispositivoRepository.crear_o_actualizar(
        user_id: 1, fcm_token: "token", platform: "android"
      )
    end
  end
end
