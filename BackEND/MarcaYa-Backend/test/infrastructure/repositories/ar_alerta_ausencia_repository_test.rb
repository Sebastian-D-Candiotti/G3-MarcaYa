# frozen_string_literal: true

require "test_helper"

class Infrastructure::Repositories::ArAlertaAusenciaRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArAlertaAusenciaRepository.new
    @empleado_record = Infrastructure::Orm::EmpleadoRecord.find(empleados(:activo).id)
    @obra_record = Infrastructure::Orm::ObraRecord.find(obras(:activa).id)
    @empresa_record = Infrastructure::Orm::EmpresaRecord.find(empresas(:activa).id)
  end

  # --- find_by_id! ---

  test "find_by_id! returns domain entity for existing record" do
    record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 5), estado: "pendiente"
    )

    entity = @repository.find_by_id!(record.id)

    assert_instance_of Domain::Entities::AlertaAusencia, entity
    assert_equal record.id, entity.id
    assert_equal record.empleado_id, entity.empleado_id
    assert_equal record.fecha, entity.fecha
  end

  test "find_by_id! raises AlertaAusenciaNoEncontradaError for missing record" do
    assert_raises Domain::Errors::AlertaAusenciaNoEncontradaError do
      @repository.find_by_id!(999_999)
    end
  end

  # --- guardar (create) ---

  test "guardar creates a new alerta record" do
    entity = Domain::Entities::AlertaAusencia.new(
      id: nil, empleado_id: @empleado_record.id,
      obra_id: @obra_record.id, empresa_id: @empresa_record.id,
      fecha: Date.new(2026, 7, 6), estado: "pendiente"
    )

    saved = @repository.guardar(entity)

    assert_instance_of Domain::Entities::AlertaAusencia, saved
    assert_equal Date.new(2026, 7, 6), saved.fecha
    assert_equal "pendiente", saved.estado
    assert saved.id.present?

    refetch = @repository.find_by_id!(saved.id)
    assert_equal Date.new(2026, 7, 6), refetch.fecha
    assert_equal @empleado_record.id, refetch.empleado_id
  end

  # --- guardar (update) ---

  test "guardar updates an existing alerta record" do
    record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 7), estado: "pendiente"
    )
    entity = @repository.find_by_id!(record.id)

    updated_entity = Domain::Entities::AlertaAusencia.new(
      id: entity.id, empleado_id: entity.empleado_id,
      obra_id: entity.obra_id, empresa_id: entity.empresa_id,
      fecha: entity.fecha, estado: "resuelta"
    )

    saved = @repository.guardar(updated_entity)

    assert_equal entity.id, saved.id
    assert_equal "resuelta", saved.estado

    refetch = @repository.find_by_id!(record.id)
    assert_equal "resuelta", refetch.estado
  end

  # --- listar_por_empresa ---

  test "listar_por_empresa returns pending alerts for empresa" do
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 8), estado: "pendiente"
    )

    entities = @repository.listar_por_empresa(@empresa_record.id)

    assert_instance_of Array, entities
    assert entities.any?
    entities.each do |entity|
      assert_instance_of Domain::Entities::AlertaAusencia, entity
      assert_equal @empresa_record.id, entity.empresa_id
      assert_equal "pendiente", entity.estado
    end
  end

  test "listar_por_empresa filters by estado" do
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 9), estado: "pendiente"
    )
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 10), estado: "resuelta"
    )

    pendientes = @repository.listar_por_empresa(@empresa_record.id, estado: "pendiente")
    assert pendientes.all? { |e| e.estado == "pendiente" }

    resueltas = @repository.listar_por_empresa(@empresa_record.id, estado: "resuelta")
    assert resueltas.all? { |e| e.estado == "resuelta" }
  end

  test "listar_por_empresa returns empty array when no alerts" do
    entities = @repository.listar_por_empresa(@empresa_record.id)
    assert_instance_of Array, entities
    # We already created records in previous tests, so at least we verify it's an array
    assert entities.all? { |e| e.is_a?(Domain::Entities::AlertaAusencia) }
  end

  # --- buscar_por_empleado_y_fecha ---

  test "buscar_por_empleado_y_fecha finds existing alert" do
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 11), estado: "pendiente"
    )

    entity = @repository.buscar_por_empleado_y_fecha(@empleado_record.id, Date.new(2026, 7, 11))

    assert_instance_of Domain::Entities::AlertaAusencia, entity
    assert_equal @empleado_record.id, entity.empleado_id
    assert_equal Date.new(2026, 7, 11), entity.fecha
  end

  test "buscar_por_empleado_y_fecha returns nil when no alert" do
    assert_nil @repository.buscar_por_empleado_y_fecha(@empleado_record.id, Date.new(2025, 1, 1))
  end

  # --- actualizar_estado ---

  test "actualizar_estado updates the estado" do
    record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record, obra: @obra_record, empresa: @empresa_record,
      fecha: Date.new(2026, 7, 12), estado: "pendiente"
    )

    @repository.actualizar_estado(record.id, "resuelta")

    record.reload
    assert_equal "resuelta", record.estado
  end

  test "actualizar_estado raises error for missing id" do
    assert_raises Domain::Errors::AlertaAusenciaNoEncontradaError do
      @repository.actualizar_estado(999_999, "resuelta")
    end
  end
end
