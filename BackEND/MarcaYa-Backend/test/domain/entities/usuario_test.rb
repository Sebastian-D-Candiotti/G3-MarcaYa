# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/value_objects/rol_usuario"
require_relative "../../../app/domain/entities/usuario"

class Domain::Entities::UsuarioTest < Minitest::Test
  def setup
    @args = {
      id: 1,
      correo: "empresa@test.com",
      clave_hash: "hashed_password",
      rol: "empresa",
      estado: true,
      codigo_recuperacion: nil,
      codigo_expira: nil,
      created_at: Time.now,
      updated_at: Time.now
    }
  end

  def test_creates_usuario_with_all_attributes
    usuario = Domain::Entities::Usuario.new(**@args)

    assert_equal 1, usuario.id
    assert_equal "empresa@test.com", usuario.correo
    assert_equal "hashed_password", usuario.clave_hash
    assert_instance_of Domain::ValueObjects::RolUsuario, usuario.rol
    assert usuario.rol.empresa?
    assert usuario.estado
    assert usuario.activo?
  end

  def test_activo_returns_true_when_estado_is_true
    usuario = Domain::Entities::Usuario.new(**@args)
    assert usuario.activo?
  end

  def test_activo_returns_false_when_estado_is_false
    args = @args.merge(estado: false)
    usuario = Domain::Entities::Usuario.new(**args)
    refute usuario.activo?
  end

  def test_es_empleado_returns_true_for_empleado_role
    args = @args.merge(rol: "empleado")
    usuario = Domain::Entities::Usuario.new(**args)
    assert usuario.es_empleado?
    refute usuario.es_empresa?
    refute usuario.es_admin?
  end

  def test_es_empresa_returns_true_for_empresa_role
    usuario = Domain::Entities::Usuario.new(**@args)
    assert usuario.es_empresa?
    refute usuario.es_empleado?
    refute usuario.es_admin?
  end

  def test_es_admin_returns_true_for_admin_role
    args = @args.merge(rol: "admin")
    usuario = Domain::Entities::Usuario.new(**args)
    assert usuario.es_admin?
    refute usuario.es_empleado?
    refute usuario.es_empresa?
  end

  def test_default_estado_is_true
    args = @args.reject { |k, _| k == :estado }
    usuario = Domain::Entities::Usuario.new(**args)
    assert usuario.estado
  end

  def test_rol_validates_inclusion
    assert_raises(ArgumentError) do
      Domain::Entities::Usuario.new(**@args.merge(rol: "invalid"))
    end
  end
end
