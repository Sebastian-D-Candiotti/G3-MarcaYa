# frozen_string_literal: true

module Infrastructure
  module Orm
    class UsuarioRecord < ActiveRecord::Base
      self.table_name = "usuarios"

      # NOTE: Password hashing is handled by BcryptPasswordService (hexagonal layer).
      # We do NOT use has_secure_password because it intercepts the clave_hash
      # column getter and returns nil, breaking our mapper.

      has_many :empleados, class_name: "Infrastructure::Orm::EmpleadoRecord",
                            foreign_key: :usuario_id,
                            dependent: :destroy
      has_many :empresas, class_name: "Infrastructure::Orm::EmpresaRecord",
                            foreign_key: :usuario_id,
                            dependent: :destroy
      has_many :informe_asistencias_generados, class_name: "Infrastructure::Orm::InformeAsistenciaRecord",
                                                foreign_key: :generado_por_id,
                                                dependent: :restrict_with_error
    end
  end
end
