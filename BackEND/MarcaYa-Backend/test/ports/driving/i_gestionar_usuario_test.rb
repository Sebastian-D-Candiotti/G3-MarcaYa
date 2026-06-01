# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driving/i_gestionar_usuario"

class Ports::Driving::IGestionarUsuarioTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driving::IGestionarUsuario
  end

  def test_obtener_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarUsuario.obtener(id: 1)
    end
  end

  def test_listar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarUsuario.listar
    end
  end

  def test_actualizar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarUsuario.actualizar(id: 1, params: { nombre: "Test" })
    end
  end

  def test_desactivar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarUsuario.desactivar(id: 1)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driving::IGestionarUsuario, :obtener
    assert_respond_to Ports::Driving::IGestionarUsuario, :listar
    assert_respond_to Ports::Driving::IGestionarUsuario, :actualizar
    assert_respond_to Ports::Driving::IGestionarUsuario, :desactivar
  end
end
