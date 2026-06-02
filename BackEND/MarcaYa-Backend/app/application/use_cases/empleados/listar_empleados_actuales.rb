# frozen_string_literal: true

module Application
  module UseCases
    module Empleados
      class ListarEmpleadosActuales
        def initialize(empleado_repo:)
          @empleado_repo = empleado_repo
        end

        def ejecutar
          @empleado_repo.todos.select(&:activo?)
        end
      end
    end
  end
end
