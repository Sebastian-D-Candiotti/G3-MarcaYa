# frozen_string_literal: true

require_relative "../test_helper"


class AsistenciaPdfServiceTest < ActiveSupport::TestCase
  Informe = Struct.new(:snapshot, :estado, :fecha_generacion, :checksum, keyword_init: true)

  test "generates valid PDF header and includes UTF-16 text" do
    informe = Informe.new(
      estado: "CERRADO",
      fecha_generacion: Time.zone.local(2026, 7, 12, 10),
      checksum: "abc123",
      snapshot: {
        "empresa" => { "nombre" => "Construcción Perú", "ruc" => "20123456789" },
        "periodo" => { "tipo" => "MENSUAL", "fecha_inicio" => "2026-07-01", "fecha_fin" => "2026-07-31" },
        "resumen" => {
          "empleados_incluidos" => 0,
          "total_marcaciones" => 0,
          "entradas" => 0,
          "salidas" => 0,
          "horas_trabajadas" => 0,
          "porcentaje_gps_valido" => 0,
          "tardanzas" => 0,
          "inasistencias" => 0,
          "justificaciones" => 0,
          "marcaciones_invalidas" => 0,
          "fake_gps" => 0
        },
        "empleados" => [],
        "limitaciones" => {}
      }
    )

    pdf = Infrastructure::Services::AsistenciaPdfService.new.call(informe)

    assert pdf.start_with?("%PDF-1.4")
    assert pdf.end_with?("%%EOF\n")
    encoded_name = "\uFEFFEmpresa: Construcción Perú".encode("UTF-16BE").unpack1("H*")
    assert_includes pdf, encoded_name
    encoded_empty = "\uFEFFSin registros para el periodo.".encode("UTF-16BE").unpack1("H*")
    assert_includes pdf, encoded_empty
  end

  test "paginates large employee collection" do
    employees = 100.times.map do |index|
      {
        "nombre" => "Empleado #{index}", "dni" => index.to_s,
        "total_marcaciones" => 2, "horas_trabajadas" => 8,
        "tardanzas" => 0, "inasistencias" => 0,
        "marcaciones_invalidas" => 0, "fake_gps" => 0
      }
    end
    base = {
      "empresa" => {}, "periodo" => {}, "resumen" => {},
      "empleados" => employees, "limitaciones" => {}
    }
    informe = Informe.new(snapshot: base, estado: "CERRADO", fecha_generacion: Time.current, checksum: "x")

    pdf = Infrastructure::Services::AsistenciaPdfService.new.call(informe)

    assert_operator pdf.scan("/Type /Page ").length, :>, 1
  end
end
