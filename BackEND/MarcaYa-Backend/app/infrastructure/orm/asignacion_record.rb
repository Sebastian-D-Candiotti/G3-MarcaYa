# frozen_string_literal: true

module Infrastructure
  module Orm
    class AsignacionRecord < ActiveRecord::Base
      self.table_name = "asignaciones"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord",
                             foreign_key: :empleado_id
      belongs_to :obra, class_name: "Infrastructure::Orm::ObraRecord",
                         foreign_key: :obra_id
    end
  end
end
