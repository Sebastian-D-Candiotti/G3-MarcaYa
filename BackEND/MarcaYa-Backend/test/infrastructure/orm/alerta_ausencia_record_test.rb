# frozen_string_literal: true

require "test_helper"

class Infrastructure::Orm::AlertaAusenciaRecordTest < ActiveSupport::TestCase
  def setup
    @empleado_record = Infrastructure::Orm::EmpleadoRecord.find(empleados(:activo).id)
    @obra_record = Infrastructure::Orm::ObraRecord.find(obras(:activa).id)
    @empresa_record = Infrastructure::Orm::EmpresaRecord.find(empresas(:activa).id)
  end

  test "table name is alerta_ausencias" do
    assert_equal "alerta_ausencias", Infrastructure::Orm::AlertaAusenciaRecord.table_name
  end

  test "belongs_to associations are defined" do
    record = Infrastructure::Orm::AlertaAusenciaRecord.new(
      empleado: @empleado_record,
      obra: @obra_record,
      empresa: @empresa_record,
      fecha: Date.new(2026, 7, 5),
      estado: "pendiente"
    )

    assert_equal @empleado_record, record.empleado
    assert_equal @obra_record, record.obra
    assert_equal @empresa_record, record.empresa
  end

  test "persists a valid record" do
    record = Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record,
      obra: @obra_record,
      empresa: @empresa_record,
      fecha: Date.new(2026, 7, 5),
      estado: "pendiente"
    )

    assert record.persisted?
    assert_equal "pendiente", record.estado
    assert_equal Date.new(2026, 7, 5), record.fecha
  end

  test "enforces unique index on empleado_id, obra_id, fecha" do
    Infrastructure::Orm::AlertaAusenciaRecord.create!(
      empleado: @empleado_record,
      obra: @obra_record,
      empresa: @empresa_record,
      fecha: Date.new(2026, 7, 5),
      estado: "pendiente"
    )

    assert_raises ActiveRecord::RecordNotUnique do
      Infrastructure::Orm::AlertaAusenciaRecord.create!(
        empleado: @empleado_record,
        obra: @obra_record,
        empresa: @empresa_record,
        fecha: Date.new(2026, 7, 5),
        estado: "pendiente"
      )
    end
  end
end
