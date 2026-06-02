# frozen_string_literal: true

require "test_helper"

class Infrastructure::Repositories::ArParadaRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArParadaRepository.new
    @obra = obras(:activa)
  end

  test "find_by_id! returns domain entity for existing record" do
    record = paradas(:entrada_principal)
    entity = @repository.find_by_id!(record.id)

    assert_instance_of Domain::Entities::Parada, entity
    assert_equal record.id, entity.id
    assert_equal record.nombre, entity.nombre
    assert_equal record.obra_id, entity.obra_id
  end

  test "find_by_id! raises ParadaNoEncontradaError for missing record" do
    assert_raises Domain::Errors::ParadaNoEncontradaError do
      @repository.find_by_id!(999_999)
    end
  end

  test "listar_por_obra returns paradas associated to the obra" do
    entities = @repository.listar_por_obra(@obra.id)

    assert_instance_of Array, entities
    assert entities.size >= 2
    entities.each do |entity|
      assert_instance_of Domain::Entities::Parada, entity
      assert_equal @obra.id, entity.obra_id
    end
  end

  test "buscar_por_nombre_y_obra returns parada domain entity if match exists" do
    record = paradas(:entrada_principal)
    entity = @repository.buscar_por_nombre_y_obra(record.nombre, record.obra_id)

    assert_instance_of Domain::Entities::Parada, entity
    assert_equal record.id, entity.id
    assert_equal record.nombre, entity.nombre
  end

  test "buscar_por_nombre_y_obra returns nil if no match exists" do
    assert_nil @repository.buscar_por_nombre_y_obra("No existe", @obra.id)
  end

  test "guardar creates a new parada record" do
    entity = Domain::Entities::Parada.new(
      id: nil,
      obra_id: @obra.id,
      nombre: "Parada Norte",
      latitud: -34.5,
      longitud: -58.5,
      radio_metros: 80,
      estado: "activa"
    )

    saved = @repository.guardar(entity)

    assert_instance_of Domain::Entities::Parada, saved
    assert_equal "Parada Norte", saved.nombre
    assert saved.id.present?

    refetch = @repository.find_by_id!(saved.id)
    assert_equal "Parada Norte", refetch.nombre
    assert_equal(-34.5, refetch.latitud)
  end

  test "guardar updates an existing parada record" do
    record = paradas(:entrada_principal)
    entity = @repository.find_by_id!(record.id)

    updated_entity = Domain::Entities::Parada.new(
      id: entity.id,
      obra_id: entity.obra_id,
      nombre: "Entrada Principal Modificada",
      latitud: entity.latitud,
      longitud: entity.longitud,
      radio_metros: 75,
      estado: "inactiva"
    )

    saved = @repository.guardar(updated_entity)

    assert_equal entity.id, saved.id
    assert_equal "Entrada Principal Modificada", saved.nombre
    assert_equal 75, saved.radio_metros
    assert_equal "inactiva", saved.estado

    refetch = @repository.find_by_id!(record.id)
    assert_equal "Entrada Principal Modificada", refetch.nombre
    assert_equal 75, refetch.radio_metros
    assert_equal "inactiva", refetch.estado
  end

  test "eliminar destroys the record" do
    record = paradas(:entrada_principal)
    entity = @repository.find_by_id!(record.id)

    result = @repository.eliminar(entity)
    assert_equal true, result

    assert_raises Domain::Errors::ParadaNoEncontradaError do
      @repository.find_by_id!(record.id)
    end
  end
end
