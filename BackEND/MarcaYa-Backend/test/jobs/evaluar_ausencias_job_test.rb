# frozen_string_literal: true

require "test_helper"

class EvaluarAusenciasJobTest < ActiveJob::TestCase
  test "is queued in default queue" do
    assert_equal "default", EvaluarAusenciasJob.new.queue_name
  end

  test "perform runs evaluation via facade" do
    # The job resolves the facade from Rails.configuration.di at runtime.
    # In test, the DI container has real repos pointing to the test DB.
    # We create test data to verify the job creates an alerta.

    empleado = empleados(:activo)
    obra = obras(:activa)
    empresa = empresas(:activa)

    # Ensure employee has an active asignacion on the active obra
    Infrastructure::Orm::AsignacionRecord
      .where(empleado_id: empleado.id, obra_id: obra.id)
      .first_or_create!(estado: "activo")

    # Set hora_inicio to a past time so tolerance is exceeded
    obra_record = Infrastructure::Orm::ObraRecord.find(obra.id)
    obra_record.update!(hora_inicio: "06:00", tolerancia_entrada_min: 0)

    # Clear any existing alertas
    Infrastructure::Orm::AlertaAusenciaRecord.where(empleado_id: empleado.id).delete_all

    assert_difference -> { Infrastructure::Orm::AlertaAusenciaRecord.count }, 1 do
      EvaluarAusenciasJob.perform_now
    end

    alerta = Infrastructure::Orm::AlertaAusenciaRecord.last
    assert_equal empleado.id, alerta.empleado_id
    assert_equal obra.id, alerta.obra_id
    assert_equal empresa.id, alerta.empresa_id
    assert_equal Date.current, alerta.fecha
    assert_equal "pendiente", alerta.estado
  end
end
