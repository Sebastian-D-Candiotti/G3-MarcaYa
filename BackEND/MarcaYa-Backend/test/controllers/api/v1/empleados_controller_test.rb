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

  # ---- PUT /api/v1/empleados/:id ----

  test "update returns 200 with updated empleado fields" do
    put "/api/v1/empleados/#{@empleado.id}", params: {
      nombre: "Carlos",
      apellido: "López",
      telefono: "999111222",
      descripcion: "Descripción actualizada"
    }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Carlos", body["nombre"]
    assert_equal "López", body["apellido"]
    assert_equal "999111222", body["telefono"]
    assert_equal "Descripción actualizada", body["descripcion"]
  end

  test "update with invalid id returns 404" do
    put "/api/v1/empleados/999999", params: { nombre: "Test" }, as: :json

    assert_response :not_found
  end

  # ---- PUT /api/v1/empleados/:id/desactivar ----

  test "desactivar returns 200 with success message" do
    put "/api/v1/empleados/#{@empleado.id}/desactivar", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Empleado desactivado correctamente", body["mensaje"]
  end

  test "desactivar with invalid id returns 404" do
    put "/api/v1/empleados/999999/desactivar", as: :json

    assert_response :not_found
  end

  # ---- GET /api/v1/empleados/:id/asistencias ----

  test "asistencias returns 200 with array of attendance records" do
    get "/api/v1/empleados/#{@empleado.id}/asistencias", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
  end

  # ---- GET /api/v1/empleados/:id/paradas ----

  test "paradas returns 200 with array of assigned paradas" do
    get "/api/v1/empleados/#{@empleado.id}/paradas", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    if body.any?
      entry = body.first
      assert entry.key?("id")
      assert entry.key?("nombre")
    end
  end
end
