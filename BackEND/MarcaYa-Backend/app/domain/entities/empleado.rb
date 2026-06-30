# frozen_string_literal: true

module Domain
  module Entities
    class Empleado
      attr_reader :id, :usuario_id, :nombre, :apellido, :dni, :estado,
                  :telefono, :descripcion, :foto_url, :device_id, :created_at, :updated_at

      def initialize(id:, usuario_id:, nombre:, apellido:, dni: nil, estado: "activo",
                     telefono: nil, descripcion: nil, foto_url: nil, device_id: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @usuario_id = usuario_id
        @nombre = nombre
        @apellido = apellido
        @dni = dni
        @estado = estado
        @telefono = telefono
        @descripcion = descripcion
        @foto_url = foto_url
        @created_at = created_at
        @updated_at = updated_at
        @device_id = device_id
      end

      def activo? = @estado == "activo"
    end
  end
end
