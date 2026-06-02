# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/asignacion"
require_relative "../../../../app/domain/entities/obra"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/asignaciones/crear_asignacion"

module Application
  module UseCases
    module Asignaciones
      class CrearAsignacionTest < Minitest::Test
        def setup
          @obra = Domain::Entities::Obra.new(
            id: 1,
            empresa_id: 10,
            nombre: "Obra Test",
            latitud: -12.0,
            longitud: -77.0,
            hora_inicio: "08:00",
            hora_fin: "17:00"
          )
        end

        def test_ejecutar_creates_and_returns_asignacion_when_company_matches
          obra_repo = Object.new
          obra_actual = @obra
          obra_repo.define_singleton_method(:find_by_id!) { |_id| obra_actual }

          asignacion_creada = Domain::Entities::Asignacion.new(
            id: 100, empleado_id: 5, obra_id: 1, estado: "activo"
          )

          asignacion_repo = Object.new
          asignacion_repo.define_singleton_method(:guardar) { |_a| asignacion_creada }

          use_case = CrearAsignacion.new(asignacion_repo: asignacion_repo, obra_repo: obra_repo)
          result = use_case.ejecutar(empleado_id: 5, obra_id: 1, empresa_id: 10)

          assert_equal asignacion_creada, result
          assert_equal 5, result.empleado_id
          assert_equal 1, result.obra_id
          assert_equal "activo", result.estado
        end

        def test_ejecutar_raises_validation_error_when_company_mismatch
          obra_repo = Object.new
          obra_actual = @obra
          obra_repo.define_singleton_method(:find_by_id!) { |_id| obra_actual }

          asignacion_repo = Object.new

          use_case = CrearAsignacion.new(asignacion_repo: asignacion_repo, obra_repo: obra_repo)

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(empleado_id: 5, obra_id: 1, empresa_id: 999) # different empresa_id
          end
        end

        def test_ejecutar_bubbles_up_error_when_obra_not_found
          obra_repo = Object.new
          obra_repo.define_singleton_method(:find_by_id!) do |_id|
            raise StandardError, "Obra no encontrada"
          end

          asignacion_repo = Object.new

          use_case = CrearAsignacion.new(asignacion_repo: asignacion_repo, obra_repo: obra_repo)

          assert_raises StandardError do
            use_case.ejecutar(empleado_id: 5, obra_id: 1, empresa_id: 10)
          end
        end
      end
    end
  end
end
