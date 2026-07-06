# frozen_string_literal: true

require "test_helper"

class Domain::Entities::AlertaAusenciaTest < ActiveSupport::TestCase
  def setup_fixtures; end
  def teardown_fixtures; end

  def setup
    @today = Date.new(2026, 7, 5)
    @now = Time.new(2026, 7, 5, 10, 30, 0)
    @valid_args = {
      id: 1,
      empleado_id: 10,
      obra_id: 20,
      empresa_id: 30,
      fecha: @today,
      estado: "pendiente",
      evaluado_en: @now,
      created_at: @now,
      updated_at: @now
    }
  end

  # --- Entity construction ---

  def test_creates_alerta_with_valid_attributes
    alerta = Domain::Entities::AlertaAusencia.new(**@valid_args)

    assert_equal 1, alerta.id
    assert_equal 10, alerta.empleado_id
    assert_equal 20, alerta.obra_id
    assert_equal 30, alerta.empresa_id
    assert_equal @today, alerta.fecha
    assert_equal "pendiente", alerta.estado
    assert_equal @now, alerta.evaluado_en
    assert_equal @now, alerta.created_at
    assert_equal @now, alerta.updated_at
  end

  # --- Default estado ---

  def test_default_estado_is_pendiente
    alerta = Domain::Entities::AlertaAusencia.new(
      id: 2, empleado_id: 10, obra_id: 20, empresa_id: 30, fecha: @today
    )

    assert_equal "pendiente", alerta.estado
    assert alerta.pendiente?
  end

  # --- Estado predicates ---

  def test_pendiente_returns_true_for_pendiente
    alerta = Domain::Entities::AlertaAusencia.new(**@valid_args)
    assert alerta.pendiente?
    refute alerta.resuelta?
  end

  def test_resuelta_returns_true_for_resuelta
    alerta = Domain::Entities::AlertaAusencia.new(**@valid_args.merge(estado: "resuelta"))
    assert alerta.resuelta?
    refute alerta.pendiente?
  end

  def test_activa_returns_true_when_pendiente
    alerta = Domain::Entities::AlertaAusencia.new(**@valid_args)
    assert alerta.activa?
  end

  def test_activa_returns_false_when_resuelta
    alerta = Domain::Entities::AlertaAusencia.new(**@valid_args.merge(estado: "resuelta"))
    refute alerta.activa?
  end

  # --- Edge cases ---

  def test_creates_without_optional_evaluado_en
    alerta = Domain::Entities::AlertaAusencia.new(
      id: 3, empleado_id: 10, obra_id: 20, empresa_id: 30, fecha: @today
    )
    assert_nil alerta.evaluado_en
  end

  def test_creates_without_optional_timestamps
    alerta = Domain::Entities::AlertaAusencia.new(
      id: 4, empleado_id: 10, obra_id: 20, empresa_id: 30, fecha: @today
    )
    assert_nil alerta.created_at
    assert_nil alerta.updated_at
  end
end
