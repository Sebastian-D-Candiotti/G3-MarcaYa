# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driving/i_autenticar_usuario"

class Ports::Driving::IAutenticarUsuarioTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driving::IAutenticarUsuario
  end

  def test_login_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IAutenticarUsuario.login(correo: "test@test.com", clave: "password")
    end
  end

  def test_registro_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IAutenticarUsuario.registro({ nombre: "Test" })
    end
  end

  def test_logout_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IAutenticarUsuario.logout(usuario_id: 1)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driving::IAutenticarUsuario, :login
    assert_respond_to Ports::Driving::IAutenticarUsuario, :registro
    assert_respond_to Ports::Driving::IAutenticarUsuario, :logout
  end
end
