# frozen_string_literal: true

require_relative "../test_helper"


class Api::V1::InformesAsistenciaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @empresa = empresas(:activa)
    @empleado = empleados(:activo)
    @obra = obras(:activa)
    @parada = paradas(:entrada_principal)
    @fecha = Date.new(2026, 5, 4)
  end

  test "generar returns daily preview without persisting a report" do
    seed_attendance!
    authenticate_as :empresa_activa

    assert_no_difference -> { Infrastructure::Orm::InformeAsistenciaRecord.count } do
      post "/api/v1/informes/asistencia/generar",
           params: {
             tipo_periodo: "DIARIO",
             fecha_inicio: @fecha.iso8601,
             fecha_fin: @fecha.iso8601
           },
           as: :json
    end

    assert_response :ok
    body = response.parsed_body
    assert_equal "DIARIO", body.dig("periodo", "tipo")
    assert_equal 2, body.dig("resumen", "total_marcaciones")
    assert_equal 1, body.dig("resumen", "tardanzas")
    assert_equal 0, body.dig("resumen", "inasistencias")
    assert_equal 8.0, body.dig("resumen", "horas_trabajadas")
  end

  test "cerrar mes creates immutable historical snapshot and rejects duplicate close" do
    seed_attendance!
    authenticate_as :empresa_activa

    assert_difference -> { Infrastructure::Orm::InformeAsistenciaRecord.count }, 1 do
      post "/api/v1/informes/asistencia/cerrar-mes",
           params: { anio: 2026, mes: 5 },
           as: :json
    end

    assert_response :created
    id = response.parsed_body.fetch("id")
    assert_equal "CERRADO", response.parsed_body.fetch("estado")
    assert_equal 2, response.parsed_body.dig("snapshot", "resumen", "total_marcaciones")

    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: @parada.id,
      tipo_marcacion: "ENTRADA",
      fecha_hora: Time.zone.local(2026, 5, 20, 8, 0, 0),
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true
    )

    get "/api/v1/informes/asistencia/#{id}"
    assert_response :ok
    assert_equal 2, response.parsed_body.dig("snapshot", "resumen", "total_marcaciones")

    post "/api/v1/informes/asistencia/cerrar-mes",
         params: { anio: 2026, mes: 5 },
         as: :json
    assert_response :conflict
  end

  test "historial lists closed reports and pdf endpoint returns a pdf file" do
    seed_attendance!
    authenticate_as :empresa_activa

    post "/api/v1/informes/asistencia/cerrar-mes",
         params: { anio: 2026, mes: 5 },
         as: :json
    assert_response :created
    id = response.parsed_body.fetch("id")

    get "/api/v1/informes/asistencia", params: { tipo_periodo: "MENSUAL", anio: 2026, mes: 5 }
    assert_response :ok
    items = response.parsed_body.fetch("items")
    assert_equal 1, items.length
    assert_equal id, items.first.fetch("id")
    assert_not items.first.key?("snapshot")

    get "/api/v1/informes/asistencia/#{id}/pdf"
    assert_response :ok
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF-1.4")
  end

  test "employee role cannot access informes endpoints" do
    authenticate_as :empleado_activo

    get "/api/v1/informes/asistencia"

    assert_response :forbidden
  end

  test "weekly preview accepts seven inclusive days and rejects eight" do
    authenticate_as :empresa_activa

    post "/api/v1/informes/asistencia/generar",
         params: {
           tipo_periodo: "SEMANAL",
           fecha_inicio: "2026-05-04",
           fecha_fin: "2026-05-10"
         },
         as: :json
    assert_response :ok
    assert_equal "SEMANAL", response.parsed_body.dig("periodo", "tipo")

    post "/api/v1/informes/asistencia/generar",
         params: {
           tipo_periodo: "SEMANAL",
           fecha_inicio: "2026-05-04",
           fecha_fin: "2026-05-11"
         },
         as: :json
    assert_response :unprocessable_entity
  end

  test "monthly preview requires exact calendar boundaries" do
    authenticate_as :empresa_activa

    post "/api/v1/informes/asistencia/generar",
         params: {
           tipo_periodo: "MENSUAL",
           fecha_inicio: "2026-05-02",
           fecha_fin: "2026-05-31"
         },
         as: :json

    assert_response :unprocessable_entity
    assert_match(/primer dia/, response.parsed_body.fetch("error"))
  end

  test "period without records returns zero summary" do
    authenticate_as :empresa_activa

    post "/api/v1/informes/asistencia/generar",
         params: {
           tipo_periodo: "DIARIO",
           fecha_inicio: "2030-01-01",
           fecha_fin: "2030-01-01"
         },
         as: :json

    assert_response :ok
    assert_equal 0, response.parsed_body.dig("resumen", "total_marcaciones")
    assert_equal 0.0, response.parsed_body.dig("resumen", "porcentaje_gps_valido")
  end

  test "unknown report pdf returns not found" do
    authenticate_as :empresa_activa

    get "/api/v1/informes/asistencia/999999/pdf"

    assert_response :not_found
  end

  private

  def seed_attendance!
    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: @parada.id,
      tipo_marcacion: "ENTRADA",
      fecha_hora: Time.zone.local(2026, 5, 4, 8, 12, 0),
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true,
      observaciones: "tardanza"
    )
    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: @parada.id,
      tipo_marcacion: "SALIDA",
      fecha_hora: Time.zone.local(2026, 5, 4, 17, 0, 0),
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true,
      duracion_jornada: 480
    )
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado_id: @empleado.id,
      obra_id: @obra.id,
      empresa_id: @empresa.id,
      fecha: Date.new(2026, 5, 5),
      estado: "pendiente"
    )
  end
end
