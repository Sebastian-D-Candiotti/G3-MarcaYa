# frozen_string_literal: true

module Application
  module UseCases
    module Auth
      class CerrarSesion
        def ejecutar(usuario_id:)
          { mensaje: "Sesión cerrada exitosamente" }
        end
      end
    end
  end
end
