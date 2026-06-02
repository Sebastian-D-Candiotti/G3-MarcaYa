# frozen_string_literal: true

require "test_helper"

class Domain::Entities::ParadaTest < ActiveSupport::TestCase
  def setup
    @now = Time.now
    @valid_args = {
      id: 1,
      obra_id: 2,
      nombre: "Entrada Principal",
      latitud: -34.603722,
      longitud: -58.381592,
      radio_metros: 50,
      estado: "activa",
      created_at: @now,
      updated_at: @now
    }
  end

  def test_creates_parada_with_valid_attributes
    parada = Domain::Entities::Parada.new(**@valid_args)

    assert_equal 1, parada.id
    assert_equal 2, parada.obra_id
    assert_equal "Entrada Principal", parada.nombre
    assert_equal(-34.603722, parada.latitud)
    assert_equal(-58.381592, parada.longitud)
    assert_equal 50, parada.radio_metros
    assert_equal "activa", parada.estado
    assert_equal @now, parada.created_at
    assert_equal @now, parada.updated_at
    assert parada.activa?
    
    # Should not raise error
    parada.validar!
  end

  def test_requires_nombre
    parada = Domain::Entities::Parada.new(**@valid_args.merge(nombre: nil))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    parada = Domain::Entities::Parada.new(**@valid_args.merge(nombre: "  "))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }
  end

  def test_requires_obra_id
    parada = Domain::Entities::Parada.new(**@valid_args.merge(obra_id: nil))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }
  end

  def test_requires_latitud_in_range
    # Too small
    parada = Domain::Entities::Parada.new(**@valid_args.merge(latitud: -90.1))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Too big
    parada = Domain::Entities::Parada.new(**@valid_args.merge(latitud: 90.1))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Non-numeric
    parada = Domain::Entities::Parada.new(**@valid_args.merge(latitud: "abc"))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }
  end

  def test_requires_longitud_in_range
    # Too small
    parada = Domain::Entities::Parada.new(**@valid_args.merge(longitud: -180.1))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Too big
    parada = Domain::Entities::Parada.new(**@valid_args.merge(longitud: 180.1))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Non-numeric
    parada = Domain::Entities::Parada.new(**@valid_args.merge(longitud: "abc"))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }
  end

  def test_requires_radio_metros_positive_integer
    # Negative
    parada = Domain::Entities::Parada.new(**@valid_args.merge(radio_metros: -5))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Zero
    parada = Domain::Entities::Parada.new(**@valid_args.merge(radio_metros: 0))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    # Float (must be Integer)
    parada = Domain::Entities::Parada.new(**@valid_args.merge(radio_metros: 50.5))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }
  end

  def test_requires_valido_estado
    parada = Domain::Entities::Parada.new(**@valid_args.merge(estado: "otro"))
    assert_raises(Domain::Errors::ValidacionError) { parada.validar! }

    parada = Domain::Entities::Parada.new(**@valid_args.merge(estado: "inactiva"))
    parada.validar!
    refute parada.activa?
  end
end
