class CreateEmpleados < ActiveRecord::Migration[8.1]
  def change
    create_table :empleados do |t|
      t.integer :empresa_id
      t.string :codigo
      t.string :nombre
      t.string :estado
      t.float :horas_trabajo_acumuladas

      t.timestamps
    end
  end
end
