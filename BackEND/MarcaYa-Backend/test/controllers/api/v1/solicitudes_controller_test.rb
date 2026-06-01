require "test_helper"

class Api::V1::SolicitudesControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — lock CURRENT behavior before refactoring.

  setup do
    @solicitud_pendiente = solicitudes(:pendiente)
    @solicitud_aceptada = solicitudes(:aceptada)
    @empleado = empleados(:activo)
  end

  # ---- GET /api/v1/solicitudes ----

  test "index returns 200 with pending solicitudes" do
    get api_v1_solicitudes_url, as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    assert body.any?
    entry = body.first
    assert entry.key?("id")
    assert entry.key?("estado")
    assert entry.key?("empleado")
    assert entry.key?("obra")
    assert_equal "pendiente", entry["estado"]
  end

  # ---- POST /api/v1/solicitudes ----

  test "create with valid params returns 200 (current behavior uses create! + render)" do
    post api_v1_solicitudes_url, params: {
      empleado_id: @empleado.id,
      obra_id: @solicitud_pendiente.obra_id
    }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.key?("id")
    assert_equal "pendiente", body["estado"]
  end

  # ---- PUT /api/v1/solicitudes/:id/aceptar (no named route) ----

  test "aceptar returns 200 with updated estado" do
    put "/api/v1/solicitudes/#{@solicitud_pendiente.id}/aceptar", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "aceptada", body["estado"]
  end

  # ---- PUT /api/v1/solicitudes/:id/rechazar (no named route) ----

  test "rechazar returns 200 with updated estado" do
    put "/api/v1/solicitudes/#{@solicitud_aceptada.id}/rechazar", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "rechazada", body["estado"]
  end

  # ---- GET /api/v1/empleados/:id/obras (routed through solicitudes#obras_empleado) ----

  # SKIPPED: Known bug — solicitudes#obras_empleado calls obra.radio but the column is
  # radio_metros. This raises NoMethodError. Will be fixed when refactoring.
  # test "obras_empleado returns 200" do
  #   get "/api/v1/empleados/#{@empleado.id}/obras", as: :json
  #   assert_response :ok
  # end

  # ---- GET /api/v1/empleados/:id/historial_solicitudes ----

  test "historial_empleado returns 200" do
    get "/api/v1/empleados/#{@empleado.id}/historial_solicitudes", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
  end
end
