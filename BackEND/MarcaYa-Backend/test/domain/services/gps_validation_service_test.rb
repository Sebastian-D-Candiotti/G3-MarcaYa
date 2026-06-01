# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/value_objects/coordenada_gps"
require_relative "../../../app/domain/services/gps_validation_service"

class Domain::Services::GpsValidationServiceTest < Minitest::Test
  def setup
    @service = Domain::Services::GpsValidationService
    # Centro de Lima: Plaza de Armas
    @centro = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.0428)
  end

  def test_punto_dentro_del_radio
    # A ~50m al este (aproximadamente 0.0005 grados de longitud)
    punto = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.0423)

    assert @service.dentro_de_geocerca?(punto, @centro, 100)
  end

  def test_punto_fuera_del_radio
    # A ~1km al sur
    punto = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0550, longitud: -77.0428)

    refute @service.dentro_de_geocerca?(punto, @centro, 100)
  end

  def test_exactamente_en_el_centro
    assert @service.dentro_de_geocerca?(@centro, @centro, 100)
  end

  def test_en_el_borde_del_radio
    # Haversine: ~89m desde el centro (0.0008 grados latitud)
    punto_borde = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0472, longitud: -77.0428)

    assert @service.dentro_de_geocerca?(punto_borde, @centro, 100)
  end

  def test_justo_fuera_del_borde
    # Haversine: ~111m desde el centro (0.0010 grados latitud)
    punto_fuera = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0474, longitud: -77.0428)

    refute @service.dentro_de_geocerca?(punto_fuera, @centro, 100)
  end

  def test_dos_puntos_muy_cercanos
    punto1 = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.0428)
    # Haversine: ~5m al este
    punto2 = Domain::ValueObjects::CoordenadaGps.new(latitud: -12.0464, longitud: -77.04275)

    assert @service.dentro_de_geocerca?(punto2, punto1, 10)
  end
end
