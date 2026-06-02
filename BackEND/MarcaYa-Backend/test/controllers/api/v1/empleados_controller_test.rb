require "test_helper"

class Api::V1::EmpleadosControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — updated for hexagonal architecture refactoring.
  # Syntax errors fixed; empleados endpoints now delegate to facades.

  setup do
    @empleado = empleados(:activo)
    authenticate_as :empleado_activo
  end

  # ---- GET /api/v1/empleados/actuales ----

  test "actuales returns 200 with array of active employees" do
    get actuales_api_v1_empleados_url, as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    assert body.any?
    entry = body.first
    assert entry.key?("id")
    assert entry.key?("nombre")
    assert entry.key?("apellido")
    assert entry.key?("dni")
    assert entry.key?("descripcion")
    assert entry.key?("telefono")
  end
end
