# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarEmpleado
    class EmpleadoFacade
      def initialize(empleado_repo:, asignacion_repo:, obra_repo:)
        @empleado_repo = empleado_repo
        @asignacion_repo = asignacion_repo
        @obra_repo = obra_repo
      end

      def obtener_obras(empleado_id:)
        UseCases::Empleados::ObtenerObrasEmpleado.new(
          empleado_repo: @empleado_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        ).ejecutar(empleado_id: empleado_id)
      end

      def listar_actuales
        UseCases::Empleados::ListarEmpleadosActuales.new(
          empleado_repo: @empleado_repo
        ).ejecutar
      end
    end
  end
end
