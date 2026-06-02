class Asignacion < ApplicationRecord
  self.table_name = 'asignaciones'

  belongs_to :empleado
  belongs_to :obra
end
