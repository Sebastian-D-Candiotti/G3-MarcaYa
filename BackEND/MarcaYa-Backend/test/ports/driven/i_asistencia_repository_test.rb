# frozen_string_literal: true

require "test_helper"

class Ports::Driven::IAsistenciaRepositoryTest < ActiveSupport::TestCase
  # Override fixture loading — pure unit test for interface
  def setup_fixtures; end
  def teardown_fixtures; end

  def test_find_by_id_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.find_by_id!(1) }
  end

  def test_buscar_entrada_activa_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.buscar_entrada_activa(1) }
  end

  def test_historial_por_empleado_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.historial_por_empleado(1) }
  end

  def test_ultimo_registro_por_empleado_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.ultimo_registro_por_empleado }
  end

  def test_ultimo_registro_por_parada_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.ultimo_registro_por_parada(1) }
  end

  def test_buscar_entrada_hoy_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.buscar_entrada_hoy(1) }
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) { Ports::Driven::IAsistenciaRepository.guardar(nil) }
  end
end
