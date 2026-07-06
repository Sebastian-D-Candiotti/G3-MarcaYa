# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/alertas/resolver_alerta"

module Application
  module UseCases
    module Alertas
      class ResolverAlertaTest < Minitest::Test
        def setup_fixtures; end
        def teardown_fixtures; end

        def test_resuelve_alerta_existente
          llamado_con = []
          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:actualizar_estado) do |id, estado|
            llamado_con << { id: id, estado: estado }
          end

          use_case = ResolverAlerta.new(alerta_repo: alerta_repo)
          use_case.ejecutar(id: 1)

          assert_equal 1, llamado_con.length
          assert_equal 1, llamado_con[0][:id]
          assert_equal "resuelta", llamado_con[0][:estado]
        end

        def test_lanza_error_si_alerta_no_existe
          alerta_repo = Object.new
          alerta_repo.define_singleton_method(:actualizar_estado) do |_id, _estado|
            raise Domain::Errors::AlertaAusenciaNoEncontradaError
          end

          use_case = ResolverAlerta.new(alerta_repo: alerta_repo)

          assert_raises Domain::Errors::AlertaAusenciaNoEncontradaError do
            use_case.ejecutar(id: 999)
          end
        end
      end
    end
  end
end
