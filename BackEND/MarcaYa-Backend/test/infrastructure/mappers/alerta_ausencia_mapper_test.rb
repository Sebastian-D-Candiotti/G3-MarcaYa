# frozen_string_literal: true

require "test_helper"

class Infrastructure::Mappers::AlertaAusenciaMapperTest < ActiveSupport::TestCase
  def setup
    @empleado_record = Infrastructure::Orm::EmpleadoRecord.find(empleados(:activo).id)
    @obra_record = Infrastructure::Orm::ObraRecord.find(obras(:activa).id)
    @empresa_record = Infrastructure::Orm::EmpresaRecord.find(empresas(:activa).id)
    @record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record,
      obra: @obra_record,
      empresa: @empresa_record,
      fecha: Date.new(2026, 7, 5),
      estado: "pendiente",
      evaluado_en: Time.new(2026, 7, 5, 10, 30, 0)
    )
  end

  test "to_domain converts record to domain entity" do
    entity = Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(@record)

    assert_instance_of Domain::Entities::AlertaAusencia, entity
    assert_equal @record.id, entity.id
    assert_equal @record.empleado_id, entity.empleado_id
    assert_equal @record.obra_id, entity.obra_id
    assert_equal @record.empresa_id, entity.empresa_id
    assert_equal @record.fecha, entity.fecha
    assert_equal @record.estado, entity.estado
    assert_equal @record.evaluado_en, entity.evaluado_en
  end

  test "to_domain handles nil" do
    assert_nil Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(nil)
  end

  test "to_record_attrs converts domain entity to attributes hash" do
    entity = Infrastructure::Mappers::AlertaAusenciaMapper.to_domain(@record)
    attrs = Infrastructure::Mappers::AlertaAusenciaMapper.to_record_attrs(entity)

    assert_instance_of Hash, attrs
    assert_equal entity.empleado_id, attrs[:empleado_id]
    assert_equal entity.obra_id, attrs[:obra_id]
    assert_equal entity.empresa_id, attrs[:empresa_id]
    assert_equal entity.fecha, attrs[:fecha]
    assert_equal entity.estado, attrs[:estado]
    assert_equal entity.evaluado_en, attrs[:evaluado_en]
    assert_equal entity.id, attrs[:id]
  end

  test "to_record_attrs excludes id for new entities" do
    entity = Domain::Entities::AlertaAusencia.new(
      id: nil,
      empleado_id: 10,
      obra_id: 20,
      empresa_id: 30,
      fecha: Date.new(2026, 7, 5),
      estado: "pendiente"
    )
    attrs = Infrastructure::Mappers::AlertaAusenciaMapper.to_record_attrs(entity)
    assert_not_includes attrs.keys, :id
  end

  test "to_record_attrs includes only non-nil timestamps" do
    entity = Domain::Entities::AlertaAusencia.new(
      id: 1, empleado_id: 10, obra_id: 20, empresa_id: 30,
      fecha: Date.new(2026, 7, 5)
    )
    attrs = Infrastructure::Mappers::AlertaAusenciaMapper.to_record_attrs(entity)
    assert_not_includes attrs.keys, :created_at
    assert_not_includes attrs.keys, :updated_at
  end
end
