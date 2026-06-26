# frozen_string_literal: true

module Infrastructure
  module Orm
    class EmpleadoRecord < ActiveRecord::Base
      self.table_name = "empleados"

      belongs_to :usuario, class_name: "Infrastructure::Orm::UsuarioRecord",
                            foreign_key: :usuario_id
      has_many :solicitudes, class_name: "Infrastructure::Orm::SolicitudRecord",
                              foreign_key: :empleado_id,
                              dependent: :destroy
      has_many :valoraciones, class_name: "Infrastructure::Orm::ValoracionRecord",
                                foreign_key: :empleado_id,
                                dependent: :destroy
      has_many :empleado_paradas, class_name: "Infrastructure::Orm::EmpleadoParadaRecord",
                                    foreign_key: :empleado_id,
                                    dependent: :destroy
      has_many :asignaciones, class_name: "Infrastructure::Orm::AsignacionRecord",
                               foreign_key: :empleado_id,
                               dependent: :destroy
      has_many :registro_asistencias, class_name: "Infrastructure::Orm::AsistenciaRecord",
                                       foreign_key: :empleado_id,
                                       dependent: :destroy
    end
  end
end

