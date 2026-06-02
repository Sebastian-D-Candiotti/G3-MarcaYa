# frozen_string_literal: true

module Application
  module UseCases
    module Paradas
      class ActualizarParada
        def initialize(parada_repo:)
          @parada_repo = parada_repo
        end

        def ejecutar(id:, params:)
          parada_existente = @parada_repo.find_by_id!(id)

          nombre_nuevo = params.key?(:nombre) ? params[:nombre] : parada_existente.nombre
          latitud_nueva = params.key?(:latitud) ? params[:latitud] : parada_existente.latitud
          longitud_nueva = params.key?(:longitud) ? params[:longitud] : parada_existente.longitud
          radio_nuevo = params.key?(:radio_metros) ? params[:radio_metros] : parada_existente.radio_metros
          estado_nuevo = params.key?(:estado) ? params[:estado] : parada_existente.estado

          parada_actualizada = Domain::Entities::Parada.new(
            id: parada_existente.id,
            obra_id: parada_existente.obra_id,
            nombre: nombre_nuevo,
            latitud: latitud_nueva,
            longitud: longitud_nueva,
            radio_metros: radio_nuevo,
            estado: estado_nuevo,
            created_at: parada_existente.created_at
          )

          parada_actualizada.validar!

          # Validar unicidad del nombre si cambió
          if nombre_nuevo != parada_existente.nombre
            existente = @parada_repo.buscar_por_nombre_y_obra(nombre_nuevo, parada_existente.obra_id)
            if existente
              raise Domain::Errors::ValidacionError, "Ya existe una parada con el nombre '#{nombre_nuevo}' en esta obra"
            end
          end

          @parada_repo.guardar(parada_actualizada)
        end
      end
    end
  end
end
