# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/application/use_cases/auth/cerrar_sesion"

module Application
  module UseCases
    module Auth
      class CerrarSesionTest < Minitest::Test
        def test_ejecutar_returns_success_message
          use_case = CerrarSesion.new
          result = use_case.ejecutar(usuario_id: 1)
          assert_equal "Sesión cerrada exitosamente", result[:mensaje]
        end
      end
    end
  end
end
