# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/value_objects/coordenada_gps"

class Domain::ValueObjects::CoordenadaGpsTest < Minitest::Test
  def test_valid_coordinates
    coord = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.0428)
    assert_in_delta(-12.0464, coord.latitud)
    assert_in_delta(-77.0428, coord.longitud)
  end

  def test_invalid_latitude_below_minus_90
    assert_raises(ArgumentError) do
      Domain::ValueObjects::CoordenadaGps.new(latitud: -91, longitud: 0)
    end
  end

  def test_invalid_latitude_above_90
    assert_raises(ArgumentError) do
      Domain::ValueObjects::CoordenadaGps.new(latitud: 91, longitud: 0)
    end
  end

  def test_invalid_longitude_below_minus_180
    assert_raises(ArgumentError) do
      Domain::ValueObjects::CoordenadaGps.new(latitud: 0, longitud: -181)
    end
  end

  def test_invalid_longitude_above_180
    assert_raises(ArgumentError) do
      Domain::ValueObjects::CoordenadaGps.new(latitud: 0, longitud: 181)
    end
  end

  def test_equality
    coord1 = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0, longitud: -77.0)
    coord2 = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0, longitud: -77.0)
    coord3 = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0, longitud: -78.0)

    assert_equal coord1, coord2
    refute_equal coord1, coord3
  end

  def test_to_s_format
    coord = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.0428)
    assert coord.to_s.include?("-12.0464")
    assert coord.to_s.include?("-77.0428")
  end

  def test_boundary_latitudes
    # Boundary values should be valid
    coord_min = Domain::ValueObjects::CoordenadaGps.new(latitud: -90.0, longitud: 0)
    coord_max = Domain::ValueObjects::CoordenadaGps.new(latitud: 90.0, longitud: 0)
    assert_equal(-90.0, coord_min.latitud)
    assert_equal(90.0, coord_max.latitud)
  end

  def test_boundary_longitudes
    coord_min = Domain::ValueObjects::CoordenadaGps.new(latitud: 0, longitud: -180.0)
    coord_max = Domain::ValueObjects::CoordenadaGps.new(latitud: 0, longitud: 180.0)
    assert_equal(-180.0, coord_min.longitud)
    assert_equal(180.0, coord_max.longitud)
  end
end
