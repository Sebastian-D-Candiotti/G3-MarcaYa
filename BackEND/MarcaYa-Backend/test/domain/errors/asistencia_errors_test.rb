# frozen_string_literal: true

require "test_helper"

class Domain::Errors::AsistenciaErrorsTest < ActiveSupport::TestCase
  # Override fixture loading — pure domain unit test
  def setup_fixtures; end
  def teardown_fixtures; end

  def test_asistencia_no_encontrada_error_inherits_standard_error
    assert Domain::Errors::AsistenciaNoEncontradaError < StandardError
  end

  def test_asistencia_no_encontrada_error_default_message
    error = Domain::Errors::AsistenciaNoEncontradaError.new
    assert_equal "Registro de asistencia no encontrado", error.message
  end

  def test_asistencia_no_encontrada_error_custom_message
    error = Domain::Errors::AsistenciaNoEncontradaError.new("custom")
    assert_equal "custom", error.message
  end

  def test_entrada_activa_existente_error_inherits_validacion_error
    assert Domain::Errors::EntradaActivaExistenteError < Domain::Errors::ValidacionError
  end

  def test_empleado_no_asignado_parada_error_inherits_validacion_error
    assert Domain::Errors::EmpleadoNoAsignadoParadaError < Domain::Errors::ValidacionError
  end

  def test_parada_inactiva_error_inherits_validacion_error
    assert Domain::Errors::ParadaInactivaError < Domain::Errors::ValidacionError
  end
end
