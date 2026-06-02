# frozen_string_literal: true

module Application
  module UseCases
    module Valoraciones
      class CrearValoracion
        def initialize(valoracion_repo:, empleado_repo:)
          @valoracion_repo = valoracion_repo
          @empleado_repo = empleado_repo
        end

        def ejecutar(empleado_id:, empresa_id:, puntuacion:, comentario: nil)
          empleado = @empleado_repo.find_by_id!(empleado_id)
          raise Domain::Errors::EmpleadoNoEncontradoError unless empleado

          valoracion = Domain::Entities::Valoracion.new(
            id: nil,
            empleado_id: empleado_id,
            empresa_id: empresa_id,
            puntuacion: puntuacion,
            comentario: comentario
          )
          @valoracion_repo.guardar(valoracion)
        end
      end
    end
  end
end
