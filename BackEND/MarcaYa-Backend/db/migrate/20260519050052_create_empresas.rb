class CreateEmpresas < ActiveRecord::Migration[8.1]
  def change
    create_table :empresas do |t|
      t.string :ruc
      t.string :razon_social
      t.integer :empleados_actuales

      t.timestamps
    end
  end
end
