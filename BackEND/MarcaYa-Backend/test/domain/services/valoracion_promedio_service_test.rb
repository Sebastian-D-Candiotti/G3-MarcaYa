# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/domain/errors"
require_relative "../../../app/domain/entities/valoracion"
require_relative "../../../app/domain/services/valoracion_promedio_service"

class Domain::Services::ValoracionPromedioServiceTest < Minitest::Test
  def setup
    @service = Domain::Services::ValoracionPromedioService
  end

  def test_promedio_de_varias_valoraciones
    valoraciones = [
      Domain::Entities::Valoracion.new(id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 5, created_at: Time.now),
      Domain::Entities::Valoracion.new(id: 2, empleado_id: 1, empresa_id: 1, puntuacion: 3, created_at: Time.now),
      Domain::Entities::Valoracion.new(id: 3, empleado_id: 1, empresa_id: 1, puntuacion: 4, created_at: Time.now)
    ]

    promedio = @service.calcular(valoraciones)
    assert_in_delta 4.0, promedio, 0.001
  end

  def test_promedio_con_una_sola_valoracion
    valoraciones = [
      Domain::Entities::Valoracion.new(id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 5, created_at: Time.now)
    ]

    promedio = @service.calcular(valoraciones)
    assert_in_delta 5.0, promedio, 0.001
  end

  def test_promedio_con_valoraciones_extremas
    valoraciones = [
      Domain::Entities::Valoracion.new(id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 1, created_at: Time.now),
      Domain::Entities::Valoracion.new(id: 2, empleado_id: 1, empresa_id: 1, puntuacion: 5, created_at: Time.now)
    ]

    promedio = @service.calcular(valoraciones)
    assert_in_delta 3.0, promedio, 0.001
  end

  def test_promedio_con_array_vacio
    assert_raises(ArgumentError) do
      @service.calcular([])
    end
  end

  def test_promedio_redondea_a_un_decimal
    valoraciones = [
      Domain::Entities::Valoracion.new(id: 1, empleado_id: 1, empresa_id: 1, puntuacion: 4, created_at: Time.now),
      Domain::Entities::Valoracion.new(id: 2, empleado_id: 1, empresa_id: 1, puntuacion: 3, created_at: Time.now)
    ]

    promedio = @service.calcular(valoraciones)
    assert_in_delta 3.5, promedio, 0.001
  end
end
