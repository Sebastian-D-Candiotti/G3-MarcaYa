# frozen_string_literal: true

module Infrastructure
  module Orm
    class SolicitudRecord < ActiveRecord::Base
      self.table_name = "solicitudes"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord",
                             foreign_key: :empleado_id
      belongs_to :empresa, class_name: "Infrastructure::Orm::EmpresaRecord",
                          foreign_key: :empresa_id
    end
  end
end
