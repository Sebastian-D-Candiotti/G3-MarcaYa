require "test_helper"

class Api::V1::ObrasControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — lock CURRENT behavior before refactoring.

  setup do
    @obra = obras(:activa)
    @empresa_id = ActiveRecord::FixtureSet.identify(:activa, :empresas)
    authenticate_as :empresa_activa
  end

  # ---- GET /api/v1/obras ----

  test "index returns 200 with all obras" do
    get api_v1_obras_url, as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    assert body.any?
    assert body.first.key?("id")
    assert body.first.key?("nombre")
  end

  # ---- GET /api/v1/obras/:id ----

  test "show returns 200 with single obra" do
    get api_v1_obra_url(@obra), as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal @obra.id, body["id"]
    assert_equal @obra.nombre, body["nombre"]
  end

  test "show for missing obra returns 404" do
    get api_v1_obra_url(id: 99999), as: :json

    assert_response :not_found
  end

  # ---- POST /api/v1/obras ----

  test "create with valid params returns 201" do
    post api_v1_obras_url, params: {
      nombre: "Nueva obra",
      empresa_id: @empresa_id,
      latitud: -12.0,
      longitud: -77.0,
      hora_inicio: "08:00:00",
      hora_fin: "17:00:00"
    }, as: :json

    assert_response :created
    body = response.parsed_body
    assert body.key?("id")
    assert_equal "Nueva obra", body["nombre"]
  end

  test "create with missing empresa_id returns 422" do
    post api_v1_obras_url, params: { nombre: "Obra sin empresa" }, as: :json

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert body.key?("errors")
  end

  # ---- PUT /api/v1/obras/:id ----

  test "update with valid params returns 200" do
    put api_v1_obra_url(@obra), params: { nombre: "Obra actualizada" }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Obra actualizada", body["nombre"]
  end

  # ---- DELETE /api/v1/obras/:id ----

  test "destroy returns 200 with success message" do
    delete api_v1_obra_url(@obra), as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Obra eliminada", body["mensaje"]
  end
end
