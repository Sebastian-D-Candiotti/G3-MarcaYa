class Empresa < ApplicationRecord

  self.table_name = 'empresas'

  validates :ruc, presence: true, 
                  uniqueness: { message: "ya está en uso" },
                  length: { is: 11, message: "debe tener 11 dígitos numéricos" },
                  numericality: { only_integer: true, message: "solo se permiten caracteres numéricos" }

end