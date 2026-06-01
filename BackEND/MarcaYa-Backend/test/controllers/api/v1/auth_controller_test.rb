require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — lock CURRENT behavior before refactoring.
  # These tests document what the existing API does, even if the behavior is not ideal.

  setup do
    @empresa = usuarios(:empresa_activa)
    @empleado = usuarios(:empleado_activo)
    @inactivo = usuarios(:empresa_inactiva)
  end

  # ---- POST /api/v1/auth/login ----

  test "login empresa with valid credentials returns 200 with token_demo and perfil" do
    post api_v1_auth_login_url, params: { correo: @empresa.correo, clave: "plaintext123" }, as: :json

    assert_response :ok
    body = response.parsed_body

    # Current behavior: hardcoded "token_demo"
    assert_equal "token_demo", body["token"]
    assert_equal "empresa", body["rol"]

    perfil = body["perfil"]
    assert_perfil_empresa_keys(perfil)
    assert_equal @empresa.id, perfil["id"]
  end

  test "login empleado with valid credentials returns 200 with token_demo and perfil" do
    post api_v1_auth_login_url, params: { correo: @empleado.correo, clave: "pass456" }, as: :json

    assert_response :ok
    body = response.parsed_body

    assert_equal "token_demo", body["token"]
    assert_equal "empleado", body["rol"]

    perfil = body["perfil"]
    assert_perfil_empleado_keys(perfil)
    assert_equal @empleado.id, perfil["id"]
  end

  test "login with wrong password returns 401" do
    post api_v1_auth_login_url, params: { correo: @empresa.correo, clave: "wrongpassword" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    # Current behavior: specific error message
    assert_equal "Contraseña incorrecta", body["error"]
  end

  test "login with unknown email returns 401" do
    post api_v1_auth_login_url, params: { correo: "unknown@test.com", clave: "anything" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    # Current behavior: specific error message
    assert_equal "Usuario no encontrado", body["error"]
  end

  test "login with inactive user returns 401" do
    post api_v1_auth_login_url, params: { correo: @inactivo.correo, clave: "secret789" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "Usuario no encontrado", body["error"]
  end

  # ---- POST /api/v1/auth/registro ----

  test "registro with valid params returns 201" do
    post api_v1_auth_registro_url, params: { correo: "nuevo@test.com", clave: "mipassword", rol: "empleado" }, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal "Usuario registrado", body["mensaje"]
    assert body["id"].present?
  end

  # ---- Helper assertions ----

  private

  def assert_perfil_empresa_keys(perfil)
    assert_perfil_base_keys(perfil)
    assert perfil.key?("nombre_empresa"), "perfil empresa debe tener nombre_empresa"
    assert perfil.key?("ruc"), "perfil empresa debe tener ruc"
    assert perfil.key?("direccion"), "perfil empresa debe tener direccion"
  end

  def assert_perfil_empleado_keys(perfil)
    assert_perfil_base_keys(perfil)
    assert perfil.key?("employee_id"), "perfil empleado debe tener employee_id"
    assert perfil.key?("apellido"), "perfil empleado debe tener apellido"
  end

  def assert_perfil_base_keys(perfil)
    assert perfil.key?("id"), "perfil debe tener id"
    assert perfil.key?("correo"), "perfil debe tener correo"
    assert perfil.key?("rol"), "perfil debe tener rol"
    assert perfil.key?("nombre"), "perfil debe tener nombre"
    assert perfil.key?("descripcion"), "perfil debe tener descripcion"
    assert perfil.key?("telefono"), "perfil debe tener telefono"
    assert perfil.key?("foto_url"), "perfil debe tener foto_url"
  end
end
