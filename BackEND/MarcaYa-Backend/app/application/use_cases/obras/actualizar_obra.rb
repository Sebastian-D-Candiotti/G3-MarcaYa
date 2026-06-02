# frozen_string_literal: true

module Application
  module UseCases
    module Obras
      class ActualizarObra
        def initialize(obra_repo:)
          @obra_repo = obra_repo
        end

        def ejecutar(id:, params:)
          obra_existente = @obra_repo.find_by_id!(id)

          obra_actualizada = Domain::Entities::Obra.new(
            id: obra_existente.id,
            empresa_id: params[:empresa_id] || obra_existente.empresa_id,
            nombre: params[:nombre] || obra_existente.nombre,
            codigo_obra: params[:codigo_obra] || obra_existente.codigo_obra,
            direccion: params[:direccion] || obra_existente.direccion,
            descripcion_ubicacion: params[:descripcion_ubicacion] || obra_existente.descripcion_ubicacion,
            latitud: params[:latitud] || obra_existente.latitud,
            longitud: params[:longitud] || obra_existente.longitud,
            radio_metros: params[:radio_metros] || obra_existente.radio_metros,
            hora_inicio: params[:hora_inicio] || obra_existente.hora_inicio,
            hora_fin: params[:hora_fin] || obra_existente.hora_fin,
            tolerancia_entrada_min: params[:tolerancia_entrada_min] || obra_existente.tolerancia_entrada_min,
            tolerancia_salida_min: params[:tolerancia_salida_min] || obra_existente.tolerancia_salida_min,
            estado: params.key?(:estado) ? params[:estado] : obra_existente.estado,
            fecha_inicio: params[:fecha_inicio] || obra_existente.fecha_inicio,
            fecha_fin: params[:fecha_fin] || obra_existente.fecha_fin,
            capacidad_empleados: params[:capacidad_empleados] || obra_existente.capacidad_empleados,
            usuario_creador_id: params[:usuario_creador_id] || obra_existente.usuario_creador_id,
            created_at: obra_existente.created_at,
            updated_at: obra_existente.updated_at
          )

          @obra_repo.guardar(obra_actualizada)
        rescue StandardError
          raise Domain::Errors::ObraNoEncontradaError
        end
      end
    end
  end
end
