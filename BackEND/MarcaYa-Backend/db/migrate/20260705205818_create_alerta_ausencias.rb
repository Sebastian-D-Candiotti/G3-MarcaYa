class CreateAlertaAusencias < ActiveRecord::Migration[8.1]
  def change
    create_table :alerta_ausencias do |t|
      t.references :empleado, null: false, foreign_key: true
      t.references :obra, null: false, foreign_key: true
      t.references :empresa, null: false, foreign_key: true
      t.date :fecha, null: false
      t.string :estado, limit: 20, default: "pendiente", null: false
      t.datetime :evaluado_en

      t.timestamps
    end

    add_index :alerta_ausencias, %i[empleado_id obra_id fecha], unique: true,
              name: "index_alerta_ausencias_on_empleado_obra_fecha"
  end
end
