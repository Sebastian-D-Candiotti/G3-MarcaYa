# frozen_string_literal: true

require "test_helper"

class CreateRegistroAsistenciasTest < ActiveSupport::TestCase
  # Override fixture loading — this test checks DB schema only
  def setup_fixtures; end
  def teardown_fixtures; end
  # --- Table existence ---
  def test_table_exists
    assert ActiveRecord::Base.connection.data_source_exists?(:registro_asistencias),
      "registro_asistencias table should exist"
  end

  # --- Column types and nullability ---
  def test_empleado_id_column
    col = column_for(:empleado_id)
    assert_includes %w[integer bigint], col.type.to_s
    assert_not col.null, "empleado_id should NOT be null"
  end

  def test_parada_id_column
    col = column_for(:parada_id)
    assert_includes %w[integer bigint], col.type.to_s
    assert_not col.null, "parada_id should NOT be null"
  end

  def test_tipo_marcacion_column
    col = column_for(:tipo_marcacion)
    assert_equal "string", col.type.to_s
    assert_not col.null, "tipo_marcacion should NOT be null"
  end

  def test_fecha_hora_column
    col = column_for(:fecha_hora)
    assert_equal "datetime", col.type.to_s
    assert_not col.null, "fecha_hora should NOT be null"
  end

  def test_latitud_registrada_column
    col = column_for(:latitud_registrada)
    assert_equal "float", col.type.to_s
    assert_not col.null, "latitud_registrada should NOT be null"
  end

  def test_longitud_registrada_column
    col = column_for(:longitud_registrada)
    assert_equal "float", col.type.to_s
    assert_not col.null, "longitud_registrada should NOT be null"
  end

  def test_valida_gps_column
    col = column_for(:valida_gps)
    assert_equal "boolean", col.type.to_s
    assert_not col.null, "valida_gps should NOT be null"
    assert_equal true, col.default, "valida_gps default should be true"
  end

  def test_duracion_jornada_column_nullable
    col = column_for(:duracion_jornada)
    assert_equal "integer", col.type.to_s
    assert col.null, "duracion_jornada should be nullable"
  end

  def test_observaciones_column_nullable
    col = column_for(:observaciones)
    assert col.null, "observaciones should be nullable"
  end

  def test_timestamps_exist
    assert ActiveRecord::Base.connection.column_exists?(:registro_asistencias, :created_at)
    assert ActiveRecord::Base.connection.column_exists?(:registro_asistencias, :updated_at)
  end

  # --- Foreign keys ---
  def test_empleado_foreign_key
    fks = ActiveRecord::Base.connection.foreign_keys(:registro_asistencias)
    fk = fks.find { |f| f.options[:column] == "empleado_id" }
    assert_not_nil fk, "Should have FK from empleado_id to empleados"
    assert_equal "empleados", fk.to_table
    assert_equal :restrict, fk.options[:on_delete]
  end

  def test_parada_foreign_key
    fks = ActiveRecord::Base.connection.foreign_keys(:registro_asistencias)
    fk = fks.find { |f| f.options[:column] == "parada_id" }
    assert_not_nil fk, "Should have FK from parada_id to paradas"
    assert_equal "paradas", fk.to_table
    assert_equal :restrict, fk.options[:on_delete]
  end

  # --- Indexes ---
  def test_tipo_marcacion_index
    indexes = ActiveRecord::Base.connection.indexes(:registro_asistencias)
    idx = indexes.find { |i| i.columns.include?("tipo_marcacion") }
    assert_not_nil idx, "Should have index on tipo_marcacion"
  end

  def test_fecha_hora_index
    indexes = ActiveRecord::Base.connection.indexes(:registro_asistencias)
    idx = indexes.find { |i| i.columns.include?("fecha_hora") }
    assert_not_nil idx, "Should have index on fecha_hora"
  end

  private

  def column_for(name)
    ActiveRecord::Base.connection.columns(:registro_asistencias).find { |c| c.name == name.to_s }
  end
end
