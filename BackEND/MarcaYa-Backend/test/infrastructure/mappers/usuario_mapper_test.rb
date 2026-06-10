# frozen_string_literal: true

require "test_helper"

# Explicitly load required files to ensure constants are available
require_relative "../../../app/domain/entities/usuario"
require_relative "../../../app/infrastructure/mappers/usuario_mapper"

class Infrastructure::Mappers::UsuarioMapperTest < ActiveSupport::TestCase
  def setup
    @usuario_record = usuarios(:empresa_activa)
  end

  test "to_domain converts record to domain entity" do
    entity = Infrastructure::Mappers::UsuarioMapper.to_domain(@usuario_record)

    assert_instance_of Domain::Entities::Usuario, entity
    assert_equal @usuario_record.id, entity.id
    assert_equal @usuario_record.correo, entity.correo
    assert_equal @usuario_record.clave_hash, entity.clave_hash
    assert_equal @usuario_record.rol, entity.rol.to_s
    assert_equal @usuario_record.estado, entity.estado
    assert_equal @usuario_record.estado_verificacion, entity.estado_verificacion
    assert_equal @usuario_record.verificado_en.to_i, entity.verificado_en.to_i
  end

  test "to_domain preserves boolean estado" do
    entity = Infrastructure::Mappers::UsuarioMapper.to_domain(@usuario_record)
    assert_equal @usuario_record.estado, entity.estado
    assert entity.activo?
  end

  test "to_domain maps timestamps" do
    entity = Infrastructure::Mappers::UsuarioMapper.to_domain(@usuario_record)
    assert_equal @usuario_record.created_at.to_i, entity.created_at.to_i
    assert_equal @usuario_record.updated_at.to_i, entity.updated_at.to_i
  end

  test "to_record_attrs converts domain entity to attributes hash" do
    entity = Infrastructure::Mappers::UsuarioMapper.to_domain(@usuario_record)
    attrs = Infrastructure::Mappers::UsuarioMapper.to_record_attrs(entity)

    assert_instance_of Hash, attrs
    assert_equal entity.correo, attrs[:correo]
    assert_equal entity.clave_hash, attrs[:clave_hash]
    assert_equal entity.rol.to_s, attrs[:rol]
    assert_equal entity.estado, attrs[:estado]
    assert_equal entity.estado_verificacion, attrs[:estado_verificacion]
    assert_equal entity.verificado_en, attrs[:verificado_en]
  end

  test "to_record_attrs excludes id for new records" do
    entity = Domain::Entities::Usuario.new(
      id: nil, correo: "nuevo@test.com", clave_hash: "hash",
      rol: "empleado"
    )
    attrs = Infrastructure::Mappers::UsuarioMapper.to_record_attrs(entity)
    assert_not_includes attrs.keys, :id
  end

  test "to_record_attrs includes timestamps when present" do
    now = Time.current
    entity = Domain::Entities::Usuario.new(
      id: 1, correo: "test@test.com", clave_hash: "hash",
      rol: "empleado", created_at: now, updated_at: now
    )
    attrs = Infrastructure::Mappers::UsuarioMapper.to_record_attrs(entity)
    assert_includes attrs.keys, :created_at
    assert_includes attrs.keys, :updated_at
  end
end
