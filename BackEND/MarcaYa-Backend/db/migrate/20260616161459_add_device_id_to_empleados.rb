#BackEND/db/migrate/20260616161459_add_device_id_to_empleados.rb
class AddDeviceIdToEmpleados < ActiveRecord::Migration[8.1]
  def change
    add_column :empleados, :device_id, :string
  end
end
