# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/i_solicitud_repository"

class Ports::Driven::ISolicitudRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::ISolicitudRepository
  end

  def test_find_by_id_bang_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::ISolicitudRepository.find_by_id!(1)
    end
  end

  def test_listar_por_empleado_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::ISolicitudRepository.listar_por_empleado(1)
    end
  end

  def test_listar_por_empresa_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::ISolicitudRepository.listar_por_empresa(1)
    end
  end

  def test_listar_pendientes_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::ISolicitudRepository.listar_pendientes
    end
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::ISolicitudRepository.guardar(:solicitud)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driven::ISolicitudRepository, :find_by_id!
    assert_respond_to Ports::Driven::ISolicitudRepository, :listar_por_empleado
    assert_respond_to Ports::Driven::ISolicitudRepository, :listar_por_empresa
    assert_respond_to Ports::Driven::ISolicitudRepository, :listar_pendientes
    assert_respond_to Ports::Driven::ISolicitudRepository, :guardar
  end
end
