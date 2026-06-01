# frozen_string_literal: true

module Infrastructure
  module Orm
    class UsuarioRecord < ActiveRecord::Base
      self.table_name = "usuarios"

      # Use has_secure_password with the existing clave_hash column
      # validations: false because existing records may have plain-text passwords
      has_secure_password :clave_hash, validations: false

      has_many :empleados, class_name: "Infrastructure::Orm::EmpleadoRecord",
                            foreign_key: :usuario_id
      has_many :empresas, class_name: "Infrastructure::Orm::EmpresaRecord",
                           foreign_key: :usuario_id
    end
  end
end
