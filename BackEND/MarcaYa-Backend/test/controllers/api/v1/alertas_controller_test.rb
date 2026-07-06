# frozen_string_literal: true

require "test_helper"

class Api::V1::AlertasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @empresa = empresas(:activa)
    @empresa_user = usuarios(:empresa_activa)
  end

  private

  def authenticate_as(user_fixture_key)
    user = usuarios(user_fixture_key)
    token = Infrastructure::Services::JwtTokenService.encode(
      "user_id" => user.id,
      "rol" => user.rol
    )
    @headers = { "Authorization" => "Bearer #{token}" }
  end

  public

  test "GET index returns 401 without authentication" do
    get api_v1_alertas_ausencias_url
    assert_response :unauthorized
  end

  test "GET index returns 403 for empleado role" do
    authenticate_as :empleado_activo
    get api_v1_alertas_ausencias_url, headers: @headers
    assert_response :forbidden
  end

  test "GET index returns empty array when no alerts" do
    authenticate_as :empresa_activa
    get api_v1_alertas_ausencias_url, headers: @headers
    assert_response :ok
    body = response.parsed_body
    assert_equal [], body
  end

  test "PUT resolver returns 401 without authentication" do
    put api_v1_alerta_resolver_url(id: 1)
    assert_response :unauthorized
  end

  test "PUT resolver returns 403 for empleado role" do
    authenticate_as :empleado_activo
    put api_v1_alerta_resolver_url(id: 1), headers: @headers
    assert_response :forbidden
  end

  test "PUT resolver returns 404 when alerta not found" do
    authenticate_as :empresa_activa
    put api_v1_alerta_resolver_url(id: 999), headers: @headers
    assert_response :not_found
    body = response.parsed_body
    assert_equal "Alerta de ausencia con id 999 no encontrada", body["error"]
  end

  test "PUT resolver returns 204 on success" do
    # Create a real alerta record for the resolver
    record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado_id: empleados(:activo).id,
      obra_id: obras(:activa).id,
      empresa_id: @empresa.id,
      fecha: Date.current,
      estado: "pendiente"
    )

    authenticate_as :empresa_activa
    put api_v1_alerta_resolver_url(id: record.id), headers: @headers
    assert_response :no_content

    record.reload
    assert_equal "resuelta", record.estado
  end
end
