# frozen_string_literal: true

module Infrastructure
  module Orm
    class ObraRecord < ActiveRecord::Base
      self.table_name = "obras"

      belongs_to :empresa, class_name: "Infrastructure::Orm::EmpresaRecord",
                            foreign_key: :empresa_id
      has_many :solicitudes, class_name: "Infrastructure::Orm::SolicitudRecord",
                              foreign_key: :obra_id
      has_many :paradas, class_name: "Infrastructure::Orm::ParadaRecord",
                           foreign_key: :obra_id, dependent: :destroy
      has_many :asignaciones, class_name: "Infrastructure::Orm::AsignacionRecord",
                               foreign_key: :obra_id
    end
  end
end

