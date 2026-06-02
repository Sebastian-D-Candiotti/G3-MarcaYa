# frozen_string_literal: true

require "test_helper"

# Explicitly load required files to ensure constants are available
require_relative "../../../app/domain/entities/usuario"
require_relative "../../../app/domain/errors"
require_relative "../../../app/infrastructure/orm/usuario_record"
require_relative "../../../app/infrastructure/mappers/usuario_mapper"
require_relative "../../../app/infrastructure/repositories/ar_usuario_repository"

class Infrastructure::Repositories::ArUsuarioRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArUsuarioRepository.new
  end

  test "find_by_id! returns domain entity for existing record" do
    record = usuarios(:empresa_activa)
    entity = @repository.find_by_id!(record.id)

    assert_instance_of Domain::Entities::Usuario, entity
    assert_equal record.id, entity.id
    assert_equal record.correo, entity.correo
  end

  test "find_by_id! raises UsuarioNoEncontradoError for missing record" do
    assert_raises Domain::Errors::UsuarioNoEncontradoError do
      @repository.find_by_id!(999_999)
    end
  end

  test "find_by_correo returns domain entity for existing email" do
    entity = @repository.find_by_correo("empresa@test.com")

    assert_instance_of Domain::Entities::Usuario, entity
    assert_equal "empresa@test.com", entity.correo
  end

  test "find_by_correo returns nil for unknown email" do
    assert_nil @repository.find_by_correo("noexiste@test.com")
  end

  test "guardar creates a new user record" do
    entity = Domain::Entities::Usuario.new(
      id: nil, correo: "nuevo@test.com",
      clave_hash: BCrypt::Password.create("password123"),
      rol: "empleado", estado: true
    )

    saved = @repository.guardar(entity)

    assert_instance_of Domain::Entities::Usuario, saved
    assert_equal "nuevo@test.com", saved.correo
    assert saved.id.present?
  end

  test "guardar updates an existing user record" do
    record = usuarios(:empleado_activo)
    entity = @repository.find_by_id!(record.id)

    updated_entity = Domain::Entities::Usuario.new(
      id: entity.id, correo: entity.correo,
      clave_hash: entity.clave_hash, rol: "empleado",
      estado: false
    )

    saved = @repository.guardar(updated_entity)

    assert_equal entity.id, saved.id
    assert_equal false, saved.estado

    refetch = @repository.find_by_id!(record.id)
    assert_equal false, refetch.estado
  end

  test "exists_by_correo? returns true for existing email" do
    assert @repository.exists_by_correo?("empresa@test.com")
  end

  test "exists_by_correo? returns false for unknown email" do
    refute @repository.exists_by_correo?("noexiste@test.com")
  end
end
