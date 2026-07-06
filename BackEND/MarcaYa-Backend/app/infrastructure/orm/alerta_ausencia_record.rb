# frozen_string_literal: true

module Infrastructure
  module Orm
    class AlertaAusenciaRecord < ActiveRecord::Base
      self.table_name = "alerta_ausencias"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord",
                             foreign_key: :empleado_id
      belongs_to :obra, class_name: "Infrastructure::Orm::ObraRecord",
                         foreign_key: :obra_id
      belongs_to :empresa, class_name: "Infrastructure::Orm::EmpresaRecord",
                            foreign_key: :empresa_id
    end
  end
end
