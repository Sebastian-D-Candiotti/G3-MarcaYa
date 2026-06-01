# frozen_string_literal: true

module Infrastructure
  module Orm
    class EmpresaRecord < ActiveRecord::Base
      self.table_name = "empresas"

      belongs_to :usuario, class_name: "Infrastructure::Orm::UsuarioRecord",
                            foreign_key: :usuario_id
      has_many :obras, class_name: "Infrastructure::Orm::ObraRecord",
                        foreign_key: :empresa_id
      has_many :valoraciones, class_name: "Infrastructure::Orm::ValoracionRecord",
                               foreign_key: :empresa_id
    end
  end
end
