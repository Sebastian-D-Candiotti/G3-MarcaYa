# frozen_string_literal: true

require_relative "../test_helper"


class InformeAsistenciaRecordTest < ActiveSupport::TestCase
  setup do
    @empresa = empresas(:activa)
    @usuario = usuarios(:empresa_activa)
  end

  test "closed report cannot be updated or destroyed" do
    record = Infrastructure::Orm::InformeAsistenciaRecord.create!(
      empresa_id: @empresa.id,
      tipo_periodo: "MENSUAL",
      fecha_inicio: Date.new(2026, 6, 1),
      fecha_fin: Date.new(2026, 6, 30),
      estado: "CERRADO",
      fecha_generacion: Time.current,
      fecha_cierre: Time.current,
      generado_por_id: @usuario.id,
      version: 1,
      snapshot: { resumen: { total_marcaciones: 1 } },
      checksum: "checksum"
    )

    refute record.update(estado: "BORRADOR")
    assert_match(/inmutable/, record.errors.full_messages.join)
    refute record.destroy
    assert Infrastructure::Orm::InformeAsistenciaRecord.exists?(record.id)
  end

  test "rejects end date before start date" do
    record = Infrastructure::Orm::InformeAsistenciaRecord.new(
      empresa_id: @empresa.id,
      tipo_periodo: "DIARIO",
      fecha_inicio: Date.new(2026, 7, 12),
      fecha_fin: Date.new(2026, 7, 11),
      estado: "BORRADOR",
      fecha_generacion: Time.current,
      generado_por_id: @usuario.id,
      snapshot: {},
      checksum: "checksum"
    )

    refute record.valid?
    assert record.errors[:fecha_fin].present?
  end
end
