# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/i_obra_repository"

class Ports::Driven::IObraRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::IObraRepository
  end

  def test_find_by_id_bang_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IObraRepository.find_by_id!(1)
    end
  end

  def test_listar_activas_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IObraRepository.listar_activas
    end
  end

  def test_listar_por_empresa_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IObraRepository.listar_por_empresa(1)
    end
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IObraRepository.guardar(:obra)
    end
  end

  def test_eliminar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IObraRepository.eliminar(:obra)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driven::IObraRepository, :find_by_id!
    assert_respond_to Ports::Driven::IObraRepository, :listar_activas
    assert_respond_to Ports::Driven::IObraRepository, :listar_por_empresa
    assert_respond_to Ports::Driven::IObraRepository, :guardar
    assert_respond_to Ports::Driven::IObraRepository, :eliminar
  end
end
