# frozen_string_literal: true

require "test_helper"

class Infrastructure::Repositories::ArEmpleadoParadaRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArEmpleadoParadaRepository.new
    @empleado = empleados(:activo)
    @parada = paradas(:entrada_principal)
  end

  test "find_by_id! returns domain entity for existing record" do
    record = empleado_paradas(:asignacion_activa)
    entity = @repository.find_by_id!(record.id)

    assert_instance_of Domain::Entities::EmpleadoParada, entity
    assert_equal record.id, entity.id
    assert_equal record.empleado_id, entity.empleado_id
    assert_equal record.parada_id, entity.parada_id
    assert entity.activo?
  end

  test "find_by_id! raises ValidacionError for missing record" do
    assert_raises Domain::Errors::ValidacionError do
      @repository.find_by_id!(999_999)
    end
  end

  test "buscar_asignacion returns domain entity if match exists" do
    record = empleado_paradas(:asignacion_activa)
    entity = @repository.buscar_asignacion(record.empleado_id, record.parada_id)

    assert_instance_of Domain::Entities::EmpleadoParada, entity
    assert_equal record.id, entity.id
    assert_equal record.empleado_id, entity.empleado_id
    assert_equal record.parada_id, entity.parada_id
  end

  test "buscar_asignacion returns nil if no match exists" do
    assert_nil @repository.buscar_asignacion(@empleado.id, 999_999)
  end

  test "listar_activos_por_parada returns only active associations" do
    entities = @repository.listar_activos_por_parada(@parada.id)

    assert_instance_of Array, entities
    assert entities.size >= 1
    entities.each do |entity|
      assert_instance_of Domain::Entities::EmpleadoParada, entity
      assert_equal @parada.id, entity.parada_id
      assert entity.activo?
    end
  end

  test "guardar creates a new record" do
    new_parada = paradas(:parada_inactiva)
    entity = Domain::Entities::EmpleadoParada.new(
      id: nil,
      empleado_id: @empleado.id,
      parada_id: new_parada.id,
      activo: true,
      estado: "activo"
    )

    saved = @repository.guardar(entity)

    assert_instance_of Domain::Entities::EmpleadoParada, saved
    assert saved.id.present?
    assert_equal @empleado.id, saved.empleado_id
    assert_equal new_parada.id, saved.parada_id
    assert saved.activo?

    refetch = @repository.find_by_id!(saved.id)
    assert refetch.activo?
  end

  test "guardar updates an existing record" do
    record = empleado_paradas(:asignacion_activa)
    entity = @repository.find_by_id!(record.id)

    updated_entity = Domain::Entities::EmpleadoParada.new(
      id: entity.id,
      empleado_id: entity.empleado_id,
      parada_id: entity.parada_id,
      activo: false,
      estado: "inactivo"
    )

    saved = @repository.guardar(updated_entity)

    assert_equal entity.id, saved.id
    refute saved.activo?
    assert_equal "inactivo", saved.estado

    refetch = @repository.find_by_id!(record.id)
    refute refetch.activo?
    assert_equal "inactivo", refetch.estado
  end
end
