# frozen_string_literal: true

module Application
  module Facades
    class ValoracionFacade
      def initialize(valoracion_repo:, empleado_repo:)
        @crear_valoracion = UseCases::Valoraciones::CrearValoracion.new(
          valoracion_repo: valoracion_repo, empleado_repo: empleado_repo
        )
        @listar_valoraciones = UseCases::Valoraciones::ListarValoracionesEmpresa.new(
          valoracion_repo: valoracion_repo
        )
        @calcular_promedio = UseCases::Valoraciones::CalcularPromedioValoracion.new(
          valoracion_repo: valoracion_repo
        )
      end

      def crear_valoracion(empleado_id:, empresa_id:, puntuacion:, comentario: nil)
        @crear_valoracion.ejecutar(
          empleado_id: empleado_id, empresa_id: empresa_id,
          puntuacion: puntuacion, comentario: comentario
        )
      end

      def listar_por_empresa(empresa_id:)
        @listar_valoraciones.ejecutar(empresa_id: empresa_id)
      end

      def promedio_empresa(empresa_id:)
        @calcular_promedio.ejecutar(empresa_id: empresa_id)
      end
    end
  end
end
