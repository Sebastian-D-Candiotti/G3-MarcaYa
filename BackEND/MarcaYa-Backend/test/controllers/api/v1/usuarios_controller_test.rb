require "test_helper"

class Api::V1::UsuariosControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — lock CURRENT behavior before refactoring.

  setup do
    @empresa = usuarios(:empresa_activa)
    @empleado = usuarios(:empleado_activo)
    authenticate_as :empresa_activa
  end

  # ---- GET /api/v1/usuarios ----

  test "index returns 200 with all usuarios" do
    get api_v1_usuarios_url, as: :json

    assert_response :ok
    body = response.parsed_body
    assert body.is_a?(Array)
    assert body.any?
    # Each user entry must have the expected keys
    body.each do |entry|
      assert entry.key?("id")
      assert entry.key?("rol")
      assert entry.key?("correo")
      assert entry.key?("nombre")
      assert entry.key?("descripcion")
    end
  end

  # ---- GET /api/v1/usuarios/:id (named route: api_v1_path) ----

  test "show empresa returns 200 with full profile" do
    get api_v1_path(id: @empresa.id), as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal @empresa.id, body["id"]
    assert_equal @empresa.correo, body["correo"]
    assert_equal "empresa", body["rol"]
    assert body.key?("nombre_empresa")
    assert body.key?("promedio_estrellas")
    assert body.key?("comentarios")
    assert body.key?("obras")
  end

  test "show empleado returns 200 with full profile" do
    get api_v1_path(id: @empleado.id), as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal @empleado.id, body["id"]
    assert_equal @empleado.correo, body["correo"]
    assert_equal "empleado", body["rol"]
    assert body.key?("nombre")
    assert body.key?("apellido")
  end

  test "show for missing usuario returns 404" do
    get api_v1_path(id: 99999), as: :json

    assert_response :not_found
  end

  # ---- PUT /api/v1/usuarios/:id (use same path helper, different verb) ----

  test "update correo returns 200 with success message" do
    put api_v1_path(id: @empleado.id), params: { correo: "nuevo@test.com" }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Usuario actualizado correctamente", body["mensaje"]
    assert_equal "nuevo@test.com", body["usuario"]["correo"]
  end

  test "update with blank correo returns 200 (no inline validation in new architecture)" do
    put api_v1_path(id: @empleado.id), params: { correo: "" }, as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "", body["usuario"]["correo"]
  end

  # ---- PATCH /api/v1/usuarios/:id/desactivar (no named route, use raw path) ----

  test "desactivar returns 200 and deactivates user" do
    patch "/api/v1/usuarios/#{@empleado.id}/desactivar", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Cuenta desactivada correctamente", body["mensaje"]
    assert_not @empleado.reload.estado
  end
end
