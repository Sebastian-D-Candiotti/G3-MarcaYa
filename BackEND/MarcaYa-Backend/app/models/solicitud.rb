class Solicitud < ApplicationRecord
  self.table_name = 'solicitudes'

  belongs_to :empleado
  belongs_to :empresa
end