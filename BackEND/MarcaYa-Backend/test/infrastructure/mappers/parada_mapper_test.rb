# frozen_string_literal: true

require "test_helper"

class Infrastructure::Mappers::ParadaMapperTest < ActiveSupport::TestCase
  def setup
    @parada_record = paradas(:entrada_principal)
  end

  test "to_domain converts record to domain entity" do
    entity = Infrastructure::Mappers::ParadaMapper.to_domain(@parada_record)

    assert_instance_of Domain::Entities::Parada, entity
    assert_equal @parada_record.id, entity.id
    assert_equal @parada_record.obra_id, entity.obra_id
    assert_equal @parada_record.nombre, entity.nombre
    assert_equal @parada_record.latitud, entity.latitud
    assert_equal @parada_record.longitud, entity.longitud
    assert_equal @parada_record.radio_metros, entity.radio_metros
    assert_equal @parada_record.estado, entity.estado
  end

  test "to_domain handles nil" do
    assert_nil Infrastructure::Mappers::ParadaMapper.to_domain(nil)
  end

  test "to_record_attrs converts domain entity to attributes hash" do
    entity = Infrastructure::Mappers::ParadaMapper.to_domain(@parada_record)
    attrs = Infrastructure::Mappers::ParadaMapper.to_record_attrs(entity)

    assert_instance_of Hash, attrs
    assert_equal entity.obra_id, attrs[:obra_id]
    assert_equal entity.nombre, attrs[:nombre]
    assert_equal entity.latitud, attrs[:latitud]
    assert_equal entity.longitud, attrs[:longitud]
    assert_equal entity.radio_metros, attrs[:radio_metros]
    assert_equal entity.estado, attrs[:estado]
    assert_equal entity.id, attrs[:id]
  end

  test "to_record_attrs excludes id for new entities" do
    entity = Domain::Entities::Parada.new(
      id: nil,
      obra_id: 2,
      nombre: "Nueva Parada",
      latitud: -34.0,
      longitud: -58.0,
      radio_metros: 50,
      estado: "activa"
    )
    attrs = Infrastructure::Mappers::ParadaMapper.to_record_attrs(entity)
    assert_not_includes attrs.keys, :id
  end
end
