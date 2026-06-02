# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/entities/asignacion"

class Domain::Entities::AsignacionTest < Minitest::Test
  def setup
    @now = Time.now
    @args = {
      id: 1,
      empleado_id: 2,
      obra_id: 3,
      estado: "activo",
      created_at: @now,
      updated_at: @now
    }
  end

  def test_creates_asignacion_with_all_attributes
    asignacion = Domain::Entities::Asignacion.new(**@args)

    assert_equal 1, asignacion.id
    assert_equal 2, asignacion.empleado_id
    assert_equal 3, asignacion.obra_id
    assert_equal "activo", asignacion.estado
    assert_equal @now, asignacion.created_at
    assert_equal @now, asignacion.updated_at
  end

  def test_creates_asignacion_with_default_estado
    args = @args.reject { |k, _| k == :estado }
    asignacion = Domain::Entities::Asignacion.new(**args)

    assert_equal "activo", asignacion.estado
  end
end
