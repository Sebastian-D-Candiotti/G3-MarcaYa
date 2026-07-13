# frozen_string_literal: true

require "test_helper"

class Api::V1::AsistenciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    authenticate_as :empleado_activo
    @empleado = empleados(:activo)
    @parada = paradas(:entrada_principal)
    @fecha_original = Time.zone.local(2026, 7, 12, 8, 15, 0)
  end

  test "sync batch preserves original timestamp and is idempotent on retry" do
    payload = {
      marcaciones: [
        marcacion_payload("offline-idempotent", @fecha_original)
      ]
    }

    assert_difference -> { Infrastructure::Orm::AsistenciaRecord.count }, 1 do
      post "/api/v1/asistencia/sincronizar", params: payload, as: :json
    end

    assert_response :ok
    assert_equal ["offline-idempotent"], response.parsed_body["sincronizados"].pluck("cliente_marcacion_id")
    record = Infrastructure::Orm::AsistenciaRecord.find_by!(cliente_marcacion_id: "offline-idempotent")
    assert_equal @fecha_original.to_i, record.fecha_hora.to_i

    assert_no_difference -> { Infrastructure::Orm::AsistenciaRecord.count } do
      post "/api/v1/asistencia/sincronizar", params: payload, as: :json
    end

    assert_response :ok
    assert_equal ["offline-idempotent"], response.parsed_body["duplicados"].pluck("cliente_marcacion_id")
  end

  test "partial batch returns 207 with synchronized and failed details" do
    post "/api/v1/asistencia/sincronizar",
         params: {
           marcaciones: [
             marcacion_payload("offline-valid", @fecha_original),
             { cliente_marcacion_id: "offline-invalid", tipo_marcacion: "ENTRADA" }
           ]
         },
         as: :json

    assert_response 207
    body = response.parsed_body
    assert_equal ["offline-valid"], body["sincronizados"].pluck("cliente_marcacion_id")
    assert_equal ["offline-invalid"], body["fallidos"].pluck("cliente_marcacion_id")
    assert_empty body["duplicados"]
  end

  test "company role cannot synchronize employee attendance" do
    @authenticated_token = nil
    authenticate_as :empresa_activa

    post "/api/v1/asistencia/sincronizar", params: { marcaciones: [] }, as: :json

    assert_response :forbidden
  end

  private

  def marcacion_payload(cliente_id, fecha)
    {
      cliente_marcacion_id: cliente_id,
      parada_id: @parada.id,
      tipo_marcacion: "ENTRADA",
      latitud: @parada.latitud,
      longitud: @parada.longitud,
      fecha_hora_original: fecha.iso8601
    }
  end
end
