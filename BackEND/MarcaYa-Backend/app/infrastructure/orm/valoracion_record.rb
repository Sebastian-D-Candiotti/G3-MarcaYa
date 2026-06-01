# frozen_string_literal: true

module Infrastructure
  module Orm
    class ValoracionRecord < ActiveRecord::Base
      self.table_name = "valoraciones"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord",
                             foreign_key: :empleado_id
      belongs_to :empresa, class_name: "Infrastructure::Orm::EmpresaRecord",
                            foreign_key: :empresa_id
    end
  end
end
