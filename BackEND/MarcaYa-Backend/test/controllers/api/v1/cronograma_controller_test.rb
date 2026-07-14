# frozen_string_literal: true

require "test_helper"

class Api::V1::CronogramaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @empresa_usuario = usuarios(:empresa_activa)
    @empleado_usuario = usuarios(:empleado_activo)
    @empleado = empleados(:activo)
    @obra = obras(:activa)
    
    # Ensure the employee has an obra assigned
    Infrastructure::Orm::AsignacionRecord
      .where(empleado_id: @empleado.id, obra_id: @obra.id)
      .first_or_create!
  end

  # ---- GET /api/v1/cronograma (Empleado) ----

  test "index returns 401 without authentication" do
    get api_v1_cronograma_url, as: :json
    assert_response :unauthorized
  end

  test "index returns 200 with employee's payrolls" do
    authenticate_as :empleado_activo
    get api_v1_cronograma_url, as: :json
    assert_response :ok
    assert response.parsed_body.is_a?(Array)
  end

  # ---- GET /api/v1/cronograma/empresa (Empresa) ----

  test "index_empresa returns 200 with all payrolls for company" do
    authenticate_as :empresa_activa
    get api_v1_cronograma_empresa_url, as: :json
    assert_response :ok
    assert response.parsed_body.is_a?(Array)
  end

  # ---- POST /api/v1/cronograma/generar (Empresa) ----

  test "generar generates payroll successfully even when no data exists" do
    authenticate_as :empresa_activa
    
    # Delete any existing asistencias first to simulate no data
    Infrastructure::Orm::AsistenciaRecord.delete_all

    post api_v1_cronograma_generar_url, params: {
      periodo_inicio: "2026-06-29",
      periodo_fin: "2026-07-31",
      tarifa_hora: 15.0
    }, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal 0, body["total_registros"]
    assert_equal "2026-06-29_2026-07-31", body["periodo"]
    assert_equal [], body["cronogramas"]
  end

  test "generar generates payroll with data successfully" do
    authenticate_as :empresa_activa
    
    # Create a parada and assistance entry
    parada = paradas(:entrada_principal)
    
    # Entrada (Entrance punch)
    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: parada.id,
      tipo_marcacion: "ENTRADA",
      fecha_hora: Time.zone.parse("2026-07-10 08:00:00"),
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true,
      duracion_jornada: nil
    )

    # Salida (Exit punch)
    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: parada.id,
      tipo_marcacion: "SALIDA",
      fecha_hora: Time.zone.parse("2026-07-10 17:00:00"),
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true,
      duracion_jornada: 540 # 9 hours (540 minutes)
    )

    post api_v1_cronograma_generar_url, params: {
      periodo_inicio: "2026-07-01",
      periodo_fin: "2026-07-31",
      tarifa_hora: 15.0
    }, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal 1, body["total_registros"]
    
    cronograma = body["cronogramas"].first
    assert_equal @empleado.id, cronograma["empleado_id"]
    assert_equal 9.0, cronograma["horas_trabajadas"]
    assert_equal 135.0, cronograma["monto_total"] # 9 hours * 15 tarifa
  end
end
