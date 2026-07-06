# frozen_string_literal: true

require "test_helper"

class DependencyInjectionTest < ActiveSupport::TestCase
  def setup_fixtures; end
  def teardown_fixtures; end

  # --- alerta_ausencia repo registration ---

  def test_alerta_ausencia_repo_is_registered
    repo = Rails.configuration.di.repos[:alerta_ausencia]

    assert_instance_of Infrastructure::Repositories::ArAlertaAusenciaRepository, repo
  end

  def test_alerta_ausencia_repo_responds_to_required_methods
    repo = Rails.configuration.di.repos[:alerta_ausencia]

    assert_respond_to repo, :guardar
    assert_respond_to repo, :listar_por_empresa
    assert_respond_to repo, :buscar_por_empleado_y_fecha
    assert_respond_to repo, :find_by_id!
    assert_respond_to repo, :actualizar_estado
  end
end
