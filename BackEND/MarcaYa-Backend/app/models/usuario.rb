class Usuario < ApplicationRecord
  validates :correo, presence: true, uniqueness: true
  validates :clave_hash, presence: true
  validates :rol, presence: true
end
