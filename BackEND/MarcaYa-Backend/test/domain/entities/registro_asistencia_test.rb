# frozen_string_literal: true

require "test_helper"

class Domain::Entities::RegistroAsistenciaTest < ActiveSupport::TestCase
  # Override fixture loading — pure domain unit test
  def setup_fixtures; end
  def teardown_fixtures; end

  def setup
    @now = Time.now
    @valid_args = {
      id: 1,
      empleado_id: 10,
      parada_id: 20,
      tipo_marcacion: "ENTRADA",
      fecha_hora: @now,
      latitud_registrada: -34.603722,
      longitud_registrada: -58.381592,
      valida_gps: true,
      duracion_jornada: nil,
      observaciones: nil,
      created_at: @now,
      updated_at: @now
    }
  end

  # --- Creation with valid attributes ---
  def test_creates_registro_with_valid_attributes
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args)

    assert_equal 1, registro.id
    assert_equal 10, registro.empleado_id
    assert_equal 20, registro.parada_id
    assert_equal "ENTRADA", registro.tipo_marcacion
    assert_equal @now, registro.fecha_hora
    assert_equal(-34.603722, registro.latitud_registrada)
    assert_equal(-58.381592, registro.longitud_registrada)
    assert registro.valida_gps
    assert_nil registro.duracion_jornada
    assert_nil registro.observaciones
    assert_equal @now, registro.created_at
    assert_equal @now, registro.updated_at
  end

  # --- entrada? / salida? helpers ---
  def test_entrada_returns_true_for_entrada
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args)
    assert registro.entrada?
    refute registro.salida?
  end

  def test_salida_returns_true_for_salida
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(
      tipo_marcacion: "SALIDA",
      duracion_jornada: 480
    ))
    assert registro.salida?
    refute registro.entrada?
  end

  # --- validar! with valid ENTRADA ---
  def test_validar_entrada_passes
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args)
    assert_nothing_raised { registro.validar! }
  end

  # --- validar! with valid SALIDA ---
  def test_validar_salida_passes
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(
      tipo_marcacion: "SALIDA",
      duracion_jornada: 480
    ))
    assert_nothing_raised { registro.validar! }
  end

  # --- validations ---
  def test_requires_empleado_id
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(empleado_id: nil))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_requires_parada_id
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(parada_id: nil))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_requires_tipo_marcacion_entrada_or_salida
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(tipo_marcacion: "INVALIDA"))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_requires_fecha_hora
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(fecha_hora: nil))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_latitud_out_of_range_raises
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(latitud_registrada: -91.0))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }

    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(latitud_registrada: 91.0))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_longitud_out_of_range_raises
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(longitud_registrada: -181.0))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }

    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(longitud_registrada: 181.0))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_duracion_jornada_nil_for_entrada_raises
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(
      tipo_marcacion: "ENTRADA",
      duracion_jornada: 100
    ))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_duracion_jornada_required_for_salida
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(
      tipo_marcacion: "SALIDA",
      duracion_jornada: nil
    ))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end

  def test_duracion_jornada_negative_for_salida_raises
    registro = Domain::Entities::RegistroAsistencia.new(**@valid_args.merge(
      tipo_marcacion: "SALIDA",
      duracion_jornada: -10
    ))
    assert_raises(Domain::Errors::ValidacionError) { registro.validar! }
  end
end
