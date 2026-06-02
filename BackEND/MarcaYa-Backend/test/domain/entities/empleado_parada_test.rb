# frozen_string_literal: true

require "test_helper"

class Domain::Entities::EmpleadoParadaTest < ActiveSupport::TestCase
  def setup
    @now = Time.now
    @valid_args = {
      id: 1,
      empleado_id: 2,
      parada_id: 3,
      activo: true,
      estado: "activo",
      created_at: @now,
      updated_at: @now
    }
  end

  def test_creates_empleado_parada_with_valid_attributes
    ep = Domain::Entities::EmpleadoParada.new(**@valid_args)

    assert_equal 1, ep.id
    assert_equal 2, ep.empleado_id
    assert_equal 3, ep.parada_id
    assert ep.activo?
    assert_equal "activo", ep.estado
    assert_equal @now, ep.created_at
    assert_equal @now, ep.updated_at
  end

  def test_inactive_empleado_parada
    ep = Domain::Entities::EmpleadoParada.new(**@valid_args.merge(activo: false, estado: "inactivo"))

    assert_equal 1, ep.id
    refute ep.activo?
    assert_equal "inactivo", ep.estado
  end
end
