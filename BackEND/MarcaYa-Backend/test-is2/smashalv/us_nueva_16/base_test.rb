# frozen_string_literal: true

require_relative "../test_helper"


class InformesAsistenciaBaseTest < ActiveSupport::TestCase
  class Harness < Application::UseCases::InformesAsistencia::Base
    public :normalizar_tipo, :validar_tipo!, :validar_rango_por_tipo!, :parse_fecha
  end

  setup do
    @subject = Harness.new
  end

  test "accepts supported period types case insensitively" do
    %w[diario semanal mensual].each do |value|
      normalized = @subject.normalizar_tipo(value)
      assert_nothing_raised { @subject.validar_tipo!(normalized) }
    end
  end

  test "rejects unknown period type" do
    error = assert_raises(ArgumentError) { @subject.validar_tipo!("ANUAL") }
    assert_match(/DIARIO, SEMANAL o MENSUAL/, error.message)
  end

  test "daily period must cover exactly one day" do
    assert_nothing_raised do
      @subject.validar_rango_por_tipo!("DIARIO", Date.new(2026, 7, 12), Date.new(2026, 7, 12))
    end
    assert_raises(ArgumentError) do
      @subject.validar_rango_por_tipo!("DIARIO", Date.new(2026, 7, 12), Date.new(2026, 7, 13))
    end
  end

  test "weekly period accepts at most seven inclusive days" do
    assert_nothing_raised do
      @subject.validar_rango_por_tipo!("SEMANAL", Date.new(2026, 7, 6), Date.new(2026, 7, 12))
    end
    assert_raises(ArgumentError) do
      @subject.validar_rango_por_tipo!("SEMANAL", Date.new(2026, 7, 5), Date.new(2026, 7, 12))
    end
  end

  test "monthly period requires exact calendar month boundaries" do
    assert_nothing_raised do
      @subject.validar_rango_por_tipo!("MENSUAL", Date.new(2026, 2, 1), Date.new(2026, 2, 28))
    end
    assert_raises(ArgumentError) do
      @subject.validar_rango_por_tipo!("MENSUAL", Date.new(2026, 2, 2), Date.new(2026, 2, 28))
    end
  end

  test "rejects reversed range and invalid date" do
    assert_raises(ArgumentError) do
      @subject.validar_rango_por_tipo!("SEMANAL", Date.new(2026, 7, 13), Date.new(2026, 7, 12))
    end
    assert_raises(ArgumentError) { @subject.parse_fecha("31/invalid", "fecha_inicio") }
  end
end
