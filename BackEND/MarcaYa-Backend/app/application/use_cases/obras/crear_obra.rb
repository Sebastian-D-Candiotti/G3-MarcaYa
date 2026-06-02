# frozen_string_literal: true

module Application
  module UseCases
    module Obras
      class CrearObra
        CAMPOS_OBLIGATORIOS = %i[empresa_id nombre latitud longitud hora_inicio hora_fin].freeze

        def initialize(obra_repo:)
          @obra_repo = obra_repo
        end

        def ejecutar(params)
          validar_campos!(params)

          obra = Domain::Entities::Obra.new(
            id: nil,
            empresa_id: params[:empresa_id],
            nombre: params[:nombre],
            codigo_obra: params[:codigo_obra],
            direccion: params[:direccion],
            descripcion_ubicacion: params[:descripcion_ubicacion],
            latitud: params[:latitud],
            longitud: params[:longitud],
            radio_metros: params[:radio_metros] || 100,
            hora_inicio: params[:hora_inicio],
            hora_fin: params[:hora_fin],
            tolerancia_entrada_min: params[:tolerancia_entrada_min] || 5,
            tolerancia_salida_min: params[:tolerancia_salida_min] || 5,
            estado: params[:estado] || "activa",
            fecha_inicio: params[:fecha_inicio],
            fecha_fin: params[:fecha_fin],
            capacidad_empleados: params[:capacidad_empleados] || 0,
            usuario_creador_id: params[:usuario_creador_id]
          )

          @obra_repo.guardar(obra)
        end

        private

        def validar_campos!(params)
          faltantes = CAMPOS_OBLIGATORIOS.select do |campo|
            params[campo].nil? || params[campo].to_s.strip.empty?
          end
          return if faltantes.empty?

          raise Domain::Errors::ValidacionError,
                "Campos obligatorios faltantes: #{faltantes.join(', ')}"
        end
      end
    end
  end
end
