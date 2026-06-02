# frozen_string_literal: true

require "test_helper"

class Infrastructure::Mappers::EmpleadoParadaMapperTest < ActiveSupport::TestCase
  def setup
    @ep_record = empleado_paradas(:asignacion_activa)
  end

  test "to_domain converts record to domain entity" do
    entity = Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(@ep_record)

    assert_instance_of Domain::Entities::EmpleadoParada, entity
    assert_equal @ep_record.id, entity.id
    assert_equal @ep_record.empleado_id, entity.empleado_id
    assert_equal @ep_record.parada_id, entity.parada_id
    assert_equal @ep_record.activo, entity.activo
    assert_equal @ep_record.estado, entity.estado
  end

  test "to_domain handles nil" do
    assert_nil Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(nil)
  end

  test "to_record_attrs converts domain entity to attributes hash" do
    entity = Infrastructure::Mappers::EmpleadoParadaMapper.to_domain(@ep_record)
    attrs = Infrastructure::Mappers::EmpleadoParadaMapper.to_record_attrs(entity)

    assert_instance_of Hash, attrs
    assert_equal entity.empleado_id, attrs[:empleado_id]
    assert_equal entity.parada_id, attrs[:parada_id]
    assert_equal entity.activo, attrs[:activo]
    assert_equal entity.estado, attrs[:estado]
    assert_equal entity.id, attrs[:id]
  end

  test "to_record_attrs excludes id for new entities" do
    entity = Domain::Entities::EmpleadoParada.new(
      id: nil,
      empleado_id: 5,
      parada_id: 10,
      activo: true,
      estado: "activo"
    )
    attrs = Infrastructure::Mappers::EmpleadoParadaMapper.to_record_attrs(entity)
    assert_not_includes attrs.keys, :id
  end
end
