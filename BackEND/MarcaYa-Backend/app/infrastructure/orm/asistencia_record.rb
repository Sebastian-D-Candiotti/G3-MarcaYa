# frozen_string_literal: true

module Infrastructure
  module Orm
    class AsistenciaRecord < ActiveRecord::Base
      self.table_name = "registro_asistencias"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord",
                             foreign_key: :empleado_id
      belongs_to :parada, class_name: "Infrastructure::Orm::ParadaRecord",
                           foreign_key: :parada_id
    end
  end
end
