class CreateEmpleadoParadas < ActiveRecord::Migration[8.1]
  def change
    create_table :empleado_paradas do |t|
      t.bigint :empleado_id, null: false
      t.bigint :parada_id, null: false
      t.boolean :activo, null: false, default: true
      t.string :estado, limit: 20, null: false, default: "activo"

      t.timestamps
    end

    add_foreign_key :empleado_paradas, :empleados, name: "empleado_paradas_empleado_id_fkey", on_delete: :cascade
    add_foreign_key :empleado_paradas, :paradas, name: "empleado_paradas_parada_id_fkey", on_delete: :cascade
    add_index :empleado_paradas, [:empleado_id, :parada_id], unique: true
  end
end
