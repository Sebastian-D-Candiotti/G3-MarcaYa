# frozen_string_literal: true

require_relative "../value_objects/rol_usuario"

module Domain
  module Entities
    class Usuario
      attr_reader :id, :correo, :clave_hash, :rol, :estado, :codigo_recuperacion,
                  :codigo_expira, :created_at, :updated_at

      def initialize(id:, correo:, clave_hash:, rol:, estado: true,
                     codigo_recuperacion: nil, codigo_expira: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @correo = correo
        @clave_hash = clave_hash
        @rol = Domain::ValueObjects::RolUsuario.new(rol)
        @estado = estado
        @codigo_recuperacion = codigo_recuperacion
        @codigo_expira = codigo_expira
        @created_at = created_at
        @updated_at = updated_at
      end

      def activo? = @estado
      def es_empleado? = @rol.empleado?
      def es_empresa? = @rol.empresa?
      def es_admin? = @rol.admin?
    end
  end
end
