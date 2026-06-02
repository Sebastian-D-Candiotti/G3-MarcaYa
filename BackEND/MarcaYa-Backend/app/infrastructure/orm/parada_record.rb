# frozen_string_literal: true

module Infrastructure
  module Orm
    class ParadaRecord < ActiveRecord::Base
      self.table_name = "paradas"

      belongs_to :obra, class_name: "Infrastructure::Orm::ObraRecord", foreign_key: :obra_id
      has_many :empleado_paradas, class_name: "Infrastructure::Orm::EmpleadoParadaRecord", foreign_key: :parada_id, dependent: :destroy
    end
  end
end
