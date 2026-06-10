class Usuario < ApplicationRecord

  self.table_name = 'usuarios'

  validates :correo,
            presence: true,
            uniqueness: true

  validates :clave_hash,
            presence: true

  validates :rol,
            presence: true

  validates :estado_verificacion,
            inclusion: {
              in: %w[PENDIENTE_VERIFICACION ACTIVO],
              allow_nil: true
            }

end
