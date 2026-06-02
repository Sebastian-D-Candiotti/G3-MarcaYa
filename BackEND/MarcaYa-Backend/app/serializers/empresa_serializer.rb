# frozen_string_literal: true

module Serializer
  module EmpresaSerializer
    def self.as_json(empresa)
      return nil if empresa.nil?

      {
        id: empresa.id,
        usuarioId: empresa.usuario_id,
        nombreEmpresa: empresa.nombre_empresa,
        ruc: empresa.ruc,
        descripcion: empresa.descripcion,
        direccion: empresa.direccion,
        telefono: empresa.telefono,
        fotoUrl: empresa.foto_url,
        estado: empresa.estado
      }
    end
  end
end
