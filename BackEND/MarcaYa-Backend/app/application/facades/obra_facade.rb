# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarObra
    class ObraFacade
      def initialize(obra_repo:)
        @obra_repo = obra_repo
      end

      def listar
        UseCases::Obras::ListarObras.new(obra_repo: @obra_repo).ejecutar
      end

      def listar_por_empresa(empresa_id:)
        @obra_repo.listar_por_empresa(empresa_id)
      end

      def obtener(id:)
        UseCases::Obras::ObtenerObra.new(obra_repo: @obra_repo).ejecutar(id: id)
      end

      def crear(params)
        UseCases::Obras::CrearObra.new(obra_repo: @obra_repo).ejecutar(params)
      end

      def actualizar(id:, params:)
        UseCases::Obras::ActualizarObra.new(obra_repo: @obra_repo).ejecutar(id: id, params: params)
      end

      def eliminar(id:)
        UseCases::Obras::EliminarObra.new(obra_repo: @obra_repo).ejecutar(id: id)
      end
    end
  end
end
