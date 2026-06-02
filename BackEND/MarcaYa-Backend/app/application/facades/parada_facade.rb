# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarParada
    class ParadaFacade
      def initialize(parada_repo:, empleado_parada_repo:, obra_repo:, empleado_repo:, asignacion_repo:)
        @parada_repo = parada_repo
        @empleado_parada_repo = empleado_parada_repo
        @obra_repo = obra_repo
        @empleado_repo = empleado_repo
        @asignacion_repo = asignacion_repo
      end

      def listar_por_obra(obra_id:)
        UseCases::Paradas::ListarParadas.new(
          parada_repo: @parada_repo,
          obra_repo: @obra_repo
        ).ejecutar(obra_id: obra_id)
      end

      def obtener(id:)
        @parada_repo.find_by_id!(id)
      end

      def crear(obra_id:, params:)
        UseCases::Paradas::CrearParada.new(
          parada_repo: @parada_repo,
          obra_repo: @obra_repo
        ).ejecutar(obra_id: obra_id, params: params)
      end

      def actualizar(id:, params:)
        UseCases::Paradas::ActualizarParada.new(
          parada_repo: @parada_repo
        ).ejecutar(id: id, params: params)
      end

      def eliminar(id:)
        UseCases::Paradas::EliminarParada.new(
          parada_repo: @parada_repo
        ).ejecutar(id: id)
      end

      def asignar_empleado(parada_id:, empleado_id:)
        UseCases::Paradas::AsignarEmpleado.new(
          parada_repo: @parada_repo,
          empleado_repo: @empleado_repo,
          empleado_parada_repo: @empleado_parada_repo,
          asignacion_repo: @asignacion_repo
        ).ejecutar(parada_id: parada_id, empleado_id: empleado_id)
      end

      def desasignar_empleado(parada_id:, empleado_id:)
        UseCases::Paradas::DesasignarEmpleado.new(
          parada_repo: @parada_repo,
          empleado_parada_repo: @empleado_parada_repo
        ).ejecutar(parada_id: parada_id, empleado_id: empleado_id)
      end

      def listar_empleados(parada_id:)
        UseCases::Paradas::ListarEmpleadosParada.new(
          parada_repo: @parada_repo,
          empleado_parada_repo: @empleado_parada_repo,
          empleado_repo: @empleado_repo
        ).ejecutar(parada_id: parada_id)
      end
    end
  end
end
