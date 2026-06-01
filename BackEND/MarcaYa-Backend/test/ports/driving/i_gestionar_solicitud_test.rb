# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driving/i_gestionar_solicitud"

class Ports::Driving::IGestionarSolicitudTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driving::IGestionarSolicitud
  end

  def test_listar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarSolicitud.listar
    end
  end

  def test_crear_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarSolicitud.crear({ empleado_id: 1, obra_id: 1 })
    end
  end

  def test_aceptar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarSolicitud.aceptar(id: 1)
    end
  end

  def test_rechazar_raises_not_implemented
    assert_raises(NotImplementedError) do
      Ports::Driving::IGestionarSolicitud.rechazar(id: 1)
    end
  end

  def test_responds_to_all_methods
    assert_respond_to Ports::Driving::IGestionarSolicitud, :listar
    assert_respond_to Ports::Driving::IGestionarSolicitud, :crear
    assert_respond_to Ports::Driving::IGestionarSolicitud, :aceptar
    assert_respond_to Ports::Driving::IGestionarSolicitud, :rechazar
  end
end
