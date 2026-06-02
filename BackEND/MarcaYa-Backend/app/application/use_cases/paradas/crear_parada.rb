# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class CrearParada
        def initialize(parada_repo:, obra_repo:)
          @parada_repo = parada_repo
          @obra_repo = obra_repo
        end

        def ejecutar(obra_id:, params:)
          # Validar que la obra exista
          @obra_repo.find_by_id!(obra_id)

          parada = Domain::Entities::Parada.new(
            id: nil,
            obra_id: obra_id,
            nombre: params[:nombre],
            latitud: params[:latitud],
            longitud: params[:longitud],
            radio_metros: params[:radio_metros] || 50,
            estado: params[:estado] || "activa"
          )

          parada.validar!

          # Validar unicidad del nombre en la obra
          existente = @parada_repo.buscar_por_nombre_y_obra(parada.nombre, obra_id)
          if existente
            raise Domain::Errors::ValidacionError, "Ya existe una parada con el nombre '#{parada.nombre}' en esta obra"
          end

          @parada_repo.guardar(parada)
        end
      end
    end
  end
end
