# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/i_usuario_repository"

class Ports::Driven::IUsuarioRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::IUsuarioRepository
  end

  def test_find_by_id_bang_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IUsuarioRepository.find_by_id!(1)
    end
  end

  def test_find_by_correo_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IUsuarioRepository.find_by_correo("test@test.com")
    end
  end

  def test_guardar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IUsuarioRepository.guardar(:usuario)
    end
  end

  def test_exists_by_correo_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driven::IUsuarioRepository.exists_by_correo?("test@test.com")
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driven::IUsuarioRepository, :find_by_id!
    assert_respond_to Ports::Driven::IUsuarioRepository, :find_by_correo
    assert_respond_to Ports::Driven::IUsuarioRepository, :guardar
    assert_respond_to Ports::Driven::IUsuarioRepository, :exists_by_correo?
  end
end
