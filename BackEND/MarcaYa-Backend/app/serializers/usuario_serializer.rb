# frozen_string_literal: true

module Serializer
  module UsuarioSerializer
    def self.as_json(usuario)
      return nil if usuario.nil?

      {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol.to_s,
        estado: usuario.estado,
        fechaRegistro: usuario.created_at
      }
    end
  end
end
