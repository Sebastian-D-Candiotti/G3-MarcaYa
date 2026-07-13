# BackEND/MarcaYa-Backend/app/application/services/calcular_metricas.rb

# frozen_string_literal: true

require_relative "../test_helper"

class CalcularMetricasTest < Minitest::Test
  def self.test(name, &block)
    define_method("test_#{name.gsub(/\s+/, '_')}", &block)
  end
  Obra = Struct.new(:id, :nombre, :hora_inicio, :tolerancia_entrada_min, keyword_init: true)
  Parada = Struct.new(:id, :obra_id, keyword_init: true)
  Empleado = Struct.new(:id, :nombre, :apellido, :estado, keyword_init: true)

  Asistencia = Struct.new(
    :empleado_id,
    :parada_id,
    :tipo_marcacion,
    :fecha_hora,
    :duracion_jornada,
    :valida_gps,
    :observaciones,
    keyword_init: true
  ) do
    def entrada?
      tipo_marcacion == "entrada"
    end

    def salida?
      tipo_marcacion == "salida"
    end
  end

  class ObraRepoFake
    def initialize(obra)
      @obra = obra
    end

    def find_by_id!(_obra_id)
      @obra
    end
  end

  class ParadaRepoFake
    def initialize(paradas)
      @paradas = paradas
    end

    def listar_por_obra(_obra_id)
      @paradas
    end
  end

  class AsistenciaRepoFake
    def initialize(asistencias)
      @asistencias = asistencias
    end

    def por_paradas_y_periodo(_parada_ids, _inicio, _fin)
      @asistencias
    end
  end

  class EmpleadoRepoFake
    def initialize(empleados)
      @empleados = empleados
    end

    def por_ids_y_estado(ids, estado)
      @empleados.select do |empleado|
        ids.include?(empleado.id) && empleado.estado == estado
      end
    end
  end

  class EmpleadoParadaRepoFake
    def initialize(empleado_ids)
      @empleado_ids = empleado_ids
    end

    def empleado_ids_por_paradas(_parada_ids)
      @empleado_ids
    end
  end

  def setup
    @obra = Obra.new(
      id: 1,
      nombre: "Obra Central",
      hora_inicio: Time.new(2026, 7, 1, 8, 0, 0),
      tolerancia_entrada_min: 5
    )

    @paradas = [
      Parada.new(id: 10, obra_id: 1)
    ]

    @empleados = [
      Empleado.new(id: 100, nombre: "Joaquin", apellido: "Gonzales", estado: "activo")
    ]

    @caso_uso = construir_caso_uso([])
  end

  test "calc_horas_totales calcula horas desde salidas" do
    salidas = [
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "salida",
        fecha_hora: Time.new(2026, 7, 1, 17, 0, 0),
        duracion_jornada: 480,
        valida_gps: true
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "salida",
        fecha_hora: Time.new(2026, 7, 2, 17, 0, 0),
        duracion_jornada: 240,
        valida_gps: true
      )
    ]

    resultado = @caso_uso.send(:calc_horas_totales, salidas)

    assert_equal 12.0, resultado
  end

  test "calc_dias_trabajados cuenta dias unicos con entrada" do
    entradas = [
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 1, 8, 0, 0),
        valida_gps: true
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 1, 8, 5, 0),
        valida_gps: true
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 2, 8, 0, 0),
        valida_gps: true
      )
    ]

    resultado = @caso_uso.send(:calc_dias_trabajados, entradas)

    assert_equal 2, resultado
  end

  test "calc_puntualidad calcula porcentaje segun entradas y tardanzas" do
    resultado = @caso_uso.send(:calc_puntualidad, 4, 1)

    assert_equal 75.0, resultado
  end

  test "detect_fake_gps identifica registros gps invalidos" do
    asistencias = [
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 1, 8, 0, 0),
        valida_gps: false,
        observaciones: nil
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 2, 8, 0, 0),
        valida_gps: true,
        observaciones: "Fake GPS Detectado"
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 3, 8, 0, 0),
        valida_gps: true,
        observaciones: nil
      )
    ]

    resultado = @caso_uso.send(:detect_fake_gps, asistencias)

    assert_equal 2, resultado.size
  end

  test "calc_faltas_total cuenta dias sin entrada por empleado" do
    empleados = [
      Empleado.new(id: 100, nombre: "Joaquin", apellido: "Gonzales", estado: "activo")
    ]

    entradas = [
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 1, 8, 0, 0),
        valida_gps: true
      )
    ]

    dias_del_periodo = [
      Date.new(2026, 7, 1),
      Date.new(2026, 7, 2),
      Date.new(2026, 7, 3)
    ]

    resultado = @caso_uso.send(:calc_faltas_total, empleados, entradas, dias_del_periodo)

    assert_equal 2, resultado
  end

  test "call integra todas las metricas principales de la obra" do
    asistencias = [
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 1, 8, 0, 0),
        valida_gps: true,
        observaciones: nil
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "salida",
        fecha_hora: Time.new(2026, 7, 1, 17, 0, 0),
        duracion_jornada: 480,
        valida_gps: true,
        observaciones: nil
      ),
      Asistencia.new(
        empleado_id: 100,
        parada_id: 10,
        tipo_marcacion: "entrada",
        fecha_hora: Time.new(2026, 7, 2, 8, 10, 0),
        valida_gps: false,
        observaciones: "Fake GPS Detectado"
      )
    ]

    caso_uso = construir_caso_uso(asistencias)

    resultado = caso_uso.call(
      obra_id: 1,
      periodo: "2026-07"
    )

    assert_equal 8.0, resultado.horas_totales
    assert_equal 4.0, resultado.horas_promedio
    assert_equal 2, resultado.dias_trabajados
    assert_equal 1, resultado.tardanzas_total
    assert_equal 50.0, resultado.puntualidad_porcentaje
    assert_equal 1, resultado.fake_gps_intentos
    assert_equal 1, resultado.empleados_con_irregularidades
  end

  private

  def construir_caso_uso(asistencias)
    Application::UseCases::Estadisticas::CalcularMetricasPersonal.new(
      obra_repo: ObraRepoFake.new(@obra),
      parada_repo: ParadaRepoFake.new(@paradas),
      asistencia_repo: AsistenciaRepoFake.new(asistencias),
      empleado_repo: EmpleadoRepoFake.new(@empleados),
      empleado_parada_repo: EmpleadoParadaRepoFake.new([100])
    )
  end
end