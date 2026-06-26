# frozen_string_literal: true

require "test_helper"

class Api::V1::AsistenciasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @empleado_usuario = usuarios(:empleado_activo)
    @empleado = empleados(:activo)
    @obra = obras(:activa)

    # Ensure the employee has an obra assigned
    Infrastructure::Orm::AsignacionRecord
      .where(empleado_id: @empleado.id, obra_id: @obra.id)
      .first_or_create!
  end

  private

  def authenticate_with_token(user)
    @authenticated_token = Infrastructure::Services::JwtTokenService.encode(
      "user_id" => user.id,
      "rol" => user.rol
    )
  end

  public

  test "estado_hoy returns 401 without authentication" do
    get api_v1_asistencia_estado_hoy_url

    assert_response :unauthorized
    body = response.parsed_body
    assert_equal "No autorizado", body["error"]
  end

  test "estado_hoy returns false when employee has not marked today" do
    authenticate_as :empleado_activo

    get api_v1_asistencia_estado_hoy_url

    assert_response :ok
    body = response.parsed_body
    assert_equal false, body["marcado_hoy"]
  end

  test "estado_hoy returns true when employee already marked entrance today" do
    authenticate_as :empleado_activo

    Infrastructure::Orm::AsistenciaRecord.create!(
      empleado_id: @empleado.id,
      parada_id: paradas(:entrada_principal).id,
      tipo_marcacion: "ENTRADA",
      fecha_hora: Time.current,
      latitud_registrada: -12.0464,
      longitud_registrada: -77.0428,
      valida_gps: true
    )

    get api_v1_asistencia_estado_hoy_url

    assert_response :ok
    body = response.parsed_body
    assert_equal true, body["marcado_hoy"]
  end

  test "estado_hoy returns 404 when employee has no obra with hora_inicio" do
    # Create an employee user with an empleado record but no asignacion
    usuario_sin_obra = ::Infrastructure::Orm::UsuarioRecord.create!(
      correo: "sinobra@test.com",
      clave_hash: "test123",
      rol: "empleado",
      estado: true,
      estado_verificacion: "ACTIVO",
      verificado_en: Time.current
    )
    ::Infrastructure::Orm::EmpleadoRecord.create!(
      usuario_id: usuario_sin_obra.id,
      nombre: "Sin",
      apellido: "Obra",
      dni: "87654321",
      estado: "activo"
    )

    authenticate_with_token(usuario_sin_obra)

    get api_v1_asistencia_estado_hoy_url

    assert_response :not_found
    body = response.parsed_body
    assert_equal "Empleado sin obra asignada con horario", body["error"]
  end
end
