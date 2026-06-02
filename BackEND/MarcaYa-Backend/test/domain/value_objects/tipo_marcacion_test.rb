# frozen_string_literal: true

require "test_helper"

class Domain::ValueObjects::TipoMarcacionTest < ActiveSupport::TestCase
  # Override fixture loading — pure domain unit test
  def setup_fixtures; end
  def teardown_fixtures; end

  # --- Constants ---
  def test_entrada_constant
    assert_equal "ENTRADA", Domain::ValueObjects::TipoMarcacion::ENTRADA
  end

  def test_salida_constant
    assert_equal "SALIDA", Domain::ValueObjects::TipoMarcacion::SALIDA
  end

  # --- entrada? ---
  def test_entrada_returns_true_for_entrada
    tipo = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    assert tipo.entrada?
  end

  def test_entrada_returns_false_for_salida
    tipo = Domain::ValueObjects::TipoMarcacion.new("SALIDA")
    refute tipo.entrada?
  end

  # --- salida? ---
  def test_salida_returns_true_for_salida
    tipo = Domain::ValueObjects::TipoMarcacion.new("SALIDA")
    assert tipo.salida?
  end

  def test_salida_returns_false_for_entrada
    tipo = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    refute tipo.salida?
  end

  # --- equality ---
  def test_equality_same_value
    tipo1 = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    tipo2 = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    assert_equal tipo1, tipo2
  end

  def test_inequality_different_value
    tipo1 = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    tipo2 = Domain::ValueObjects::TipoMarcacion.new("SALIDA")
    refute_equal tipo1, tipo2
  end

  def test_equality_with_string
    tipo = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    assert_equal tipo, "ENTRADA"
  end

  # --- to_s ---
  def test_to_s_returns_value
    tipo = Domain::ValueObjects::TipoMarcacion.new("ENTRADA")
    assert_equal "ENTRADA", tipo.to_s
  end

  # --- invalid value raises ---
  def test_invalid_value_raises_argument_error
    assert_raises(ArgumentError) { Domain::ValueObjects::TipoMarcacion.new("INVALIDA") }
  end
end
