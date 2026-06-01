# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/i_valoracion_repository"

class Ports::Driven::IValoracionRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::IValoracionRepository
  end

  def test_listar_por_empresa_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IValoracionRepository.listar_por_empresa(1)
    end
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IValoracionRepository.guardar(:valoracion)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driven::IValoracionRepository, :listar_por_empresa
    assert_respond_to Ports::Driven::IValoracionRepository, :guardar
  end
end
