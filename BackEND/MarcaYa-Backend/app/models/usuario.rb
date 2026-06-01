class Usuario < ApplicationRecord

  self.table_name = 'usuarios'

  validates :correo,
            presence: true,
            uniqueness: true

  validates :clave_hash,
            presence: true

  validates :rol,
            presence: true

end