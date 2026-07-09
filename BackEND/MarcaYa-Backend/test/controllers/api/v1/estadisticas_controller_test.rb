# frozen_string_literal: true

require "test_helper"

class Api::V1::EstadisticasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @obra = obras(:activa)
  end

  test "GET por_obra returns 200 with metricas for empresa" do
    authenticate_as :empresa_activa
    get "/api/v1/estadisticas/obra/#{@obra.id}?periodo=2026-06", as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal @obra.id, body["obra_id"]
    assert_equal "2026-06", body["periodo"]
    assert body.key?("horas_totales")
    assert body.key?("puntualidad_porcentaje")
    assert body.key?("datos_por_empleado")
  end

  test "GET por_obra without auth returns 401" do
    get "/api/v1/estadisticas/obra/1?periodo=2026-06", as: :json

    assert_response :unauthorized
  end

  test "GET por_obra with empleado role returns 403" do
    authenticate_as :empleado_activo

    get "/api/v1/estadisticas/obra/1?periodo=2026-06", as: :json

    assert_response :forbidden
  end

  test "GET por_obra with nonexistent obra returns 404" do
    authenticate_as :empresa_activa
    get "/api/v1/estadisticas/obra/99999?periodo=2026-06", as: :json

    assert_response :not_found
  end
end
