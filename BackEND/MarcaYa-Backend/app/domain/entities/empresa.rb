# frozen_string_literal: true

module Domain
  module Entities
    class Empresa
      attr_reader :id, :usuario_id, :nombre_empresa, :ruc, :descripcion,
                  :direccion, :telefono, :foto_url, :estado,
                  :created_at, :updated_at

      def initialize(id:, usuario_id:, nombre_empresa:, ruc:,
                     descripcion: nil, direccion: nil, telefono: nil,
                     foto_url: nil, estado: "activo",
                     created_at: nil, updated_at: nil)
        @id = id
        @usuario_id = usuario_id
        @nombre_empresa = nombre_empresa
        @ruc = ruc
        @descripcion = descripcion
        @direccion = direccion
        @telefono = telefono
        @foto_url = foto_url
        @estado = estado
        @created_at = created_at
        @updated_at = updated_at
      end

      def activo? = @estado == "activo"
    end
  end
end
