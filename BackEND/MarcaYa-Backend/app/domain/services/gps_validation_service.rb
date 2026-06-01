# frozen_string_literal: true

module Domain
  module Services
    class GpsValidationService
      RADIO_TIERRA_KM = 6371.0

      def self.dentro_de_geocerca?(coordenada, centro_coordenada, radio_metros)
        distancia = haversine_distance(
          coordenada.latitud, coordenada.longitud,
          centro_coordenada.latitud, centro_coordenada.longitud
        )
        distancia <= radio_metros
      end

      def self.haversine_distance(lat1, lon1, lat2, lon2)
        dlat = to_radians(lat2 - lat1)
        dlon = to_radians(lon2 - lon1)

        a = Math.sin(dlat / 2)**2 +
            Math.cos(to_radians(lat1)) * Math.cos(to_radians(lat2)) *
            Math.sin(dlon / 2)**2

        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

        # Return distance in meters
        RADIO_TIERRA_KM * c * 1000
      end

      def self.to_radians(degrees)
        degrees * Math::PI / 180
      end

      private_class_method :haversine_distance, :to_radians
    end
  end
end
