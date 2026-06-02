# frozen_string_literal: true

module Application
  module UseCases
    module Empresa
      class ObtenerEmpresa
        def initialize(empresa_repo:)
          @empresa_repo = empresa_repo
        end

        def ejecutar(usuario_id:)
          @empresa_repo.find_by_usuario_id(usuario_id)
        end
      end
    end
  end
end
