# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/empresa"
require_relative "../../../../app/application/use_cases/empresa/obtener_empresa"

module Application
  module UseCases
    module Empresa
      class ObtenerEmpresaTest < Minitest::Test
        def test_ejecutar_returns_empresa
          empresa = Domain::Entities::Empresa.new(
            id: 1, usuario_id: 1, nombre_empresa: "Constructora ABC", ruc: "12345678901"
          )

          repo = Object.new
          repo.define_singleton_method(:find_by_usuario_id) { |_uid| empresa }

          use_case = ObtenerEmpresa.new(empresa_repo: repo)
          result = use_case.ejecutar(usuario_id: 1)

          assert_equal empresa, result
        end

        def test_ejecutar_returns_nil_when_not_found
          repo = Object.new
          repo.define_singleton_method(:find_by_usuario_id) { |_uid| nil }

          use_case = ObtenerEmpresa.new(empresa_repo: repo)
          result = use_case.ejecutar(usuario_id: 999)

          assert_nil result
        end
      end
    end
  end
end
