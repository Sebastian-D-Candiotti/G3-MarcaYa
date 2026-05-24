class Usuario < ApplicationRecord
  has_secure_password

  before_save :normalizar_correo

  validates :correo, presence: true, uniqueness: { case_sensitive: false }
  validates :clave_hash, presence: true
  validates :rol, presence: true, inclusion: { in: %w[empleado empresa admin] }

  enum :estado, { activo: 'activo', inactivo: 'inactivo' }, default: :activo

  private

  def normalizar_correo
    self.correo = correo.strip.downcase if correo.present?
  end
end
