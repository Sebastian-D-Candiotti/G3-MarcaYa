require "test_helper"

class Api::V1::SolicitudesControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — updated for hexagonal architecture refactoring.
  # Domain rules now enforce valid state transitions (pendiente -> aceptada/rechazada).

  setup do
    @solicitud_pendiente = solicitudes(:pendiente)
    @solicitud_aceptada = solicitudes(:aceptada)
    @empleado = empleados(:activo)
    authenticate_as :empresa_activa
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
    assert entry.key?("empresa")
    refute entry.key?("obra")
    assert_equal "pendiente", entry["estado"]
  end

  # ---- POST /api/v1/solicitudes ----

  test "create with valid params returns 422 when duplicate (domain rule enforced)" do
    post api_v1_solicitudes_url, params: {
      empleado_id: @empleado.id,
      empresa_id: @solicitud_pendiente.empresa_id
    }, as: :json

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_includes body["errors"].first, "solicitud pendiente"
  end

  test "create with valid params for another company succeeds" do
    empresa_b = empresas(:empresa_b)
    post api_v1_solicitudes_url, params: {
      empleado_id: @empleado.id,
      empresa_id: empresa_b.id
    }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "pendiente", body["estado"]
    assert_equal empresa_b.id, body["empresaId"]
  end

  # ---- PUT /api/v1/solicitudes/:id/aceptar ----

  test "aceptar returns 200 with updated estado when company matches" do
    obra = obras(:activa)
    put "/api/v1/solicitudes/#{@solicitud_pendiente.id}/aceptar", params: { obra_id: obra.id }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "aceptada", body["estado"]
  end

  test "aceptar returns 422 when obra belongs to different company" do
    obra_mismatch = obras(:obra_b)
    put "/api/v1/solicitudes/#{@solicitud_pendiente.id}/aceptar", params: { obra_id: obra_mismatch.id }, as: :json

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_equal "La obra no pertenece a la empresa de la solicitud", body["error"]
  end

  # ---- PUT /api/v1/solicitudes/:id/rechazar ----

  test "rechazar returns 200 with updated estado" do
    # Use a pending solicitud — domain rules enforce valid state transitions
    put "/api/v1/solicitudes/#{@solicitud_pendiente.id}/rechazar", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "rechazada", body["estado"]
  end

  # ---- GET /api/v1/empleados/:id/obras (routed through solicitudes#obras_empleado) ----

  test "obras_empleado returns 200 with array of works for the employee" do
    get "/api/v1/empleados/#{@empleado.id}/obras", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
  end

  # ---- GET /api/v1/empleados/:id/historial_solicitudes ----

  test "historial_empleado returns 200" do
    get "/api/v1/empleados/#{@empleado.id}/historial_solicitudes", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    entry = body.first
    assert entry.key?("empresa")
    refute entry.key?("obra")
  end

  # ---- GET /api/v1/solicitudes/:id ----

  test "show returns 200 with solicitud data" do
    get "/api/v1/solicitudes/#{@solicitud_pendiente.id}", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal @solicitud_pendiente.id, body["id"]
    assert_equal "pendiente", body["estado"]
    assert body.key?("empleado")
    assert body.key?("empresa")
  end

  test "show with invalid id returns 404" do
    get "/api/v1/solicitudes/999999", as: :json

    assert_response :not_found
  end

  # ---- GET /api/v1/solicitudes/mis-solicitudes ----

  test "mis_solicitudes as empleado returns 200 with filtered solicitudes" do
    authenticate_as :empleado_activo
    get "/api/v1/solicitudes/mis-solicitudes", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    if body.any?
      entry = body.first
      assert entry.key?("id")
      assert entry.key?("estado")
      assert entry.key?("empresa")
    end
  end

  test "mis_solicitudes as empresa returns 200 with empty array (no empleado)" do
    authenticate_as :empresa_activa
    get "/api/v1/solicitudes/mis-solicitudes", as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    assert body.empty?
  end
end
