# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driving/i_gestionar_obra"

class Ports::Driving::IGestionarObraTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driving::IGestionarObra
  end

  def test_listar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarObra.listar
    end
  end

  def test_obtener_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarObra.obtener(id: 1)
    end
  end

  def test_crear_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarObra.crear({ nombre: "Obra Test" })
    end
  end

  def test_actualizar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarObra.actualizar(id: 1, params: { nombre: "Nuevo" })
    end
  end

  def test_eliminar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarObra.eliminar(id: 1)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driving::IGestionarObra, :listar
    assert_respond_to Ports::Driving::IGestionarObra, :obtener
    assert_respond_to Ports::Driving::IGestionarObra, :crear
    assert_respond_to Ports::Driving::IGestionarObra, :actualizar
    assert_respond_to Ports::Driving::IGestionarObra, :eliminar
  end
end
