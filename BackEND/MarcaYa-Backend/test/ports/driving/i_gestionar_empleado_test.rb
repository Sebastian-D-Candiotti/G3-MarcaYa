# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driving/i_gestionar_empleado"

class Ports::Driving::IGestionarEmpleadoTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driving::IGestionarEmpleado
  end

  def test_obtener_obras_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarEmpleado.obtener_obras(empleado_id: 1)
    end
  end

  def test_listar_actuales_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarEmpleado.listar_actuales
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driving::IGestionarEmpleado, :obtener_obras
    assert_respond_to Ports::Driving::IGestionarEmpleado, :listar_actuales
  end
end
