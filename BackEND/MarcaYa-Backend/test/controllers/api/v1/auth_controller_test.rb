require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  # Characterization tests — updated for hexagonal architecture refactoring.
  # Auth now uses bcrypt + JWT (not plain text + token_demo).

  setup do
    @empresa = usuarios(:empresa_activa)
    @empleado = usuarios(:empleado_activo)
    @inactivo = usuarios(:empresa_inactiva)
    @pendiente = usuarios(:empleado_pendiente)
    ActionMailer::Base.deliveries.clear
  end

  # ---- POST /api/v1/auth/login ----

  test "login empresa with valid credentials returns 200 with token and perfil" do
    post api_v1_auth_login_url, params: { correo: @empresa.correo, clave: "plaintext123" }, as: :json

    assert_response :ok
    body = response.parsed_body

    # Auth now returns a real JWT instead of "token_demo"
    assert body["token"].present?
    assert_equal "empresa", body["rol"]

    perfil = body["perfil"]
    assert_perfil_empresa_keys(perfil)
    assert_equal @empresa.id, perfil["id"]
  end

  test "login empleado with valid credentials returns 200 with token and perfil" do
    post api_v1_auth_login_url, params: { correo: @empleado.correo, clave: "pass456" }, as: :json

    assert_response :ok
    body = response.parsed_body

    assert body["token"].present?
    assert_equal "empleado", body["rol"]

    perfil = body["perfil"]
    assert_perfil_empleado_keys(perfil)
    assert_equal @empleado.id, perfil["id"]
  end

  test "login with wrong password returns 401" do
    post api_v1_auth_login_url, params: { correo: @empresa.correo, clave: "wrongpassword" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "Contrasena incorrecta", body["error"]
  end

  test "login with unknown email returns 401" do
    post api_v1_auth_login_url, params: { correo: "unknown@test.com", clave: "anything" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "Usuario no encontrado", body["error"]
  end

  test "login with inactive user returns 401" do
    post api_v1_auth_login_url, params: { correo: @inactivo.correo, clave: "secret789" }, as: :json

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "Usuario no encontrado", body["error"]
  end

  test "login with pending verification user returns 403" do
    post api_v1_auth_login_url, params: { correo: @pendiente.correo, clave: "pending123" }, as: :json

    assert_response :forbidden
    body = response.parsed_body
    assert_equal "Cuenta pendiente de verificacion", body["error"]
  end

  # ---- POST /api/v1/auth/registro ----

  test "registro with valid params returns 201" do
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      post api_v1_auth_registro_url, params: {
        correo: "nuevo@test.com", clave: "mipassword",
        rol: "empleado", nombre: "Nuevo", apellido: "Usuario"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "Usuario registrado. Revisa tu correo para verificar la cuenta.", body["mensaje"]
    assert body["id"].present?
    assert_equal "PENDIENTE_VERIFICACION", body["estado_verificacion"]
    assert_equal true, body["requiere_verificacion"]
    assert_nil body["token"]

    usuario = Usuario.find_by!(correo: "nuevo@test.com")
    assert_equal false, usuario.estado
    assert_equal "PENDIENTE_VERIFICACION", usuario.estado_verificacion
    assert usuario.codigo_verificacion_digest.present?
    assert usuario.codigo_verificacion_expira_en.present?
  end

  test "verificar cuenta with valid code activates pending user" do
    post "/api/v1/auth/verificacion/verificar",
         params: { correo: @pendiente.correo, codigo: "123456" },
         as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "Cuenta verificada", body["mensaje"]
    assert_equal "ACTIVO", body["usuario"]["estado_verificacion"]

    @pendiente.reload
    assert_equal true, @pendiente.estado
    assert_equal "ACTIVO", @pendiente.estado_verificacion
    assert_nil @pendiente.codigo_verificacion_digest
    assert_nil @pendiente.codigo_verificacion_expira_en
  end

  test "verificar cuenta with wrong code returns 422" do
    post "/api/v1/auth/verificacion/verificar",
         params: { correo: @pendiente.correo, codigo: "999999" },
         as: :json

    assert_response :unprocessable_entity
    assert_equal "Codigo incorrecto", response.parsed_body["error"]
  end

  test "reenviar codigo updates pending verification code" do
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      post "/api/v1/auth/verificacion/reenviar",
           params: { correo: @pendiente.correo },
           as: :json
    end

    assert_response :ok
    assert_equal "Codigo reenviado", response.parsed_body["mensaje"]

    @pendiente.reload
    assert_equal false, @pendiente.estado
    assert_equal "PENDIENTE_VERIFICACION", @pendiente.estado_verificacion
    assert @pendiente.codigo_verificacion_digest.present?
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
