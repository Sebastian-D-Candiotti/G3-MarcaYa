# frozen_string_literal: true

require "test_helper"

class Infrastructure::Repositories::ArObraRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = Infrastructure::Repositories::ArObraRepository.new
  end

  test "listar_activas_con_asignaciones returns active obras with asignaciones" do
    results = @repository.listar_activas_con_asignaciones

    assert_instance_of Array, results
    assert results.any?, "Should have at least one active obra with asignaciones"

    results.each do |entry|
      assert_includes entry.keys, :obra
      assert_includes entry.keys, :asignaciones

      assert_instance_of Domain::Entities::Obra, entry[:obra]
      assert entry[:obra].activa?, "Obra should be active"

      assert_instance_of Array, entry[:asignaciones]
      entry[:asignaciones].each do |asignacion|
        assert_instance_of Domain::Entities::Asignacion, asignacion
        assert_equal "activo", asignacion.estado
        assert_equal entry[:obra].id, asignacion.obra_id
      end
    end
  end

  test "listar_activas_con_asignaciones includes employee id in each asignacion" do
    results = @repository.listar_activas_con_asignaciones

    assert results.any? { |e| e[:asignaciones].any? },
           "At least one active obra should have asignaciones"

    results.each do |entry|
      entry[:asignaciones].each do |asignacion|
        assert asignacion.empleado_id.present?,
               "Asignacion #{asignacion.id} should have an empleado_id"
      end
    end
  end

  test "listar_activas_con_asignaciones does not include inactive obras" do
    all_obras = @repository.todos
    active_count = all_obras.count(&:activa?)

    results = @repository.listar_activas_con_asignaciones

    assert_equal active_count, results.size,
                 "Results should only include active obras"
  end
end
