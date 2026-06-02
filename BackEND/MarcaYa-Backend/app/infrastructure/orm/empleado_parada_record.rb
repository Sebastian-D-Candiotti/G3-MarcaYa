# frozen_string_literal: true

module Infrastructure
  module Orm
    class EmpleadoParadaRecord < ActiveRecord::Base
      self.table_name = "empleado_paradas"

      belongs_to :empleado, class_name: "Infrastructure::Orm::EmpleadoRecord", foreign_key: :empleado_id
      belongs_to :parada, class_name: "Infrastructure::Orm::ParadaRecord", foreign_key: :parada_id
    end
  end
end
