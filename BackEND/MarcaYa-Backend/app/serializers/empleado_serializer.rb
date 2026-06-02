# frozen_string_literal: true

module Serializer
  module EmpleadoSerializer
    def self.as_json(empleado)
      return nil if empleado.nil?

      {
        id: empleado.id,
        usuarioId: empleado.usuario_id,
        nombre: empleado.nombre,
        apellido: empleado.apellido,
        dni: empleado.dni,
        estado: empleado.estado,
        telefono: empleado.telefono,
        descripcion: empleado.descripcion,
        fotoUrl: empleado.foto_url
      }
    end
  end
end
