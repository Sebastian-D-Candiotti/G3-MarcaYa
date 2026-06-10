# frozen_string_literal: true

require_relative "../value_objects/rol_usuario"

module Domain
  module Entities
    class Usuario
      ESTADO_VERIFICACION_PENDIENTE = "PENDIENTE_VERIFICACION"
      ESTADO_VERIFICACION_ACTIVO = "ACTIVO"

      attr_reader :id, :correo, :clave_hash, :rol, :estado, :codigo_recuperacion,
                  :codigo_expira, :estado_verificacion, :codigo_verificacion_digest,
                  :codigo_verificacion_expira_en, :verificado_en, :created_at,
                  :updated_at

      def initialize(id:, correo:, clave_hash:, rol:, estado: true,
                     codigo_recuperacion: nil, codigo_expira: nil,
                     estado_verificacion: ESTADO_VERIFICACION_ACTIVO,
                     codigo_verificacion_digest: nil,
                     codigo_verificacion_expira_en: nil,
                     verificado_en: nil,
                     created_at: nil, updated_at: nil)
        @id = id
        @correo = correo
        @clave_hash = clave_hash
        @rol = Domain::ValueObjects::RolUsuario.new(rol)
        @estado = estado
        @codigo_recuperacion = codigo_recuperacion
        @codigo_expira = codigo_expira
        @estado_verificacion = estado_verificacion || ESTADO_VERIFICACION_ACTIVO
        @codigo_verificacion_digest = codigo_verificacion_digest
        @codigo_verificacion_expira_en = codigo_verificacion_expira_en
        @verificado_en = verificado_en
        @created_at = created_at
        @updated_at = updated_at
      end

      def activo? = @estado
      def pendiente_verificacion? = @estado_verificacion == ESTADO_VERIFICACION_PENDIENTE
      def verificado? = @estado_verificacion == ESTADO_VERIFICACION_ACTIVO
      def es_empleado? = @rol.empleado?
      def es_empresa? = @rol.empresa?
      def es_admin? = @rol.admin?
    end
  end
end
