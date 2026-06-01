class AddDniToEmpleados < ActiveRecord::Migration[8.1]
  def change
    add_column :empleados, :dni, :string
  end
end
