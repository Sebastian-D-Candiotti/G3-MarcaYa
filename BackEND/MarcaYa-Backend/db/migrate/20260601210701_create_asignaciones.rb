class CreateAsignaciones < ActiveRecord::Migration[8.1]
  def change
    create_table :asignaciones do |t|
      t.bigint :empleado_id, null: false
      t.bigint :obra_id, null: false
      t.string :estado, limit: 20, default: "activo"

      t.timestamps
    end

    add_foreign_key :asignaciones, :empleados, name: "asignaciones_empleado_id_fkey"
    add_foreign_key :asignaciones, :obras, name: "asignaciones_obra_id_fkey"
  end
end
