# frozen_string_literal: true

require_relative "../value_objects/coordenada_gps"

module Domain
  module Entities
    class Obra
      attr_reader :id, :empresa_id, :nombre, :codigo_obra, :direccion,
                  :descripcion_ubicacion, :latitud, :longitud, :radio_metros,
                  :hora_inicio, :hora_fin, :tolerancia_entrada_min,
                  :tolerancia_salida_min, :estado, :fecha_inicio, :fecha_fin,
                  :capacidad_empleados, :usuario_creador_id,
                  :created_at, :updated_at

      def initialize(id:, empresa_id:, nombre:, codigo_obra: nil, direccion: nil,
                     descripcion_ubicacion: nil, latitud:, longitud:,
                     radio_metros: 100, hora_inicio:, hora_fin:,
                     tolerancia_entrada_min: 5, tolerancia_salida_min: 5,
                     estado: "activa", fecha_inicio: nil, fecha_fin: nil,
                     capacidad_empleados: 0, usuario_creador_id: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @empresa_id = empresa_id
        @nombre = nombre
        @codigo_obra = codigo_obra
        @direccion = direccion
        @descripcion_ubicacion = descripcion_ubicacion
        @latitud = latitud
        @longitud = longitud
        @radio_metros = radio_metros
        @hora_inicio = hora_inicio
        @hora_fin = hora_fin
        @tolerancia_entrada_min = tolerancia_entrada_min
        @tolerancia_salida_min = tolerancia_salida_min
        @estado = estado
        @fecha_inicio = fecha_inicio
        @fecha_fin = fecha_fin
        @capacidad_empleados = capacidad_empleados
        @usuario_creador_id = usuario_creador_id
        @created_at = created_at
        @updated_at = updated_at
      end

      def activa? = @estado == "activa"

      def geocerca
        Domain::ValueObjects::CoordenadaGps.new(latitud: @latitud, longitud: @longitud)
      end
    end
  end
end
