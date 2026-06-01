# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/i_empleado_repository"

class Ports::Driven::IEmpleadoRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::IEmpleadoRepository
  end

  def test_find_by_id_bang_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IEmpleadoRepository.find_by_id!(1)
    end
  end

  def test_find_by_usuario_id_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IEmpleadoRepository.find_by_usuario_id(1)
    end
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IEmpleadoRepository.guardar(:empleado)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driven::IEmpleadoRepository, :find_by_id!
    assert_respond_to Ports::Driven::IEmpleadoRepository, :find_by_usuario_id
    assert_respond_to Ports::Driven::IEmpleadoRepository, :guardar
  end
end
