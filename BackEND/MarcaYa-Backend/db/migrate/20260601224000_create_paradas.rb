class CreateParadas < ActiveRecord::Migration[8.1]
  def change
    create_table :paradas do |t|
      t.bigint :obra_id, null: false
      t.string :nombre, limit: 150, null: false
      t.float :latitud, null: false
      t.float :longitud, null: false
      t.integer :radio_metros, null: false, default: 50
      t.string :estado, limit: 20, null: false, default: "activa"

      t.timestamps
    end

    add_foreign_key :paradas, :obras, name: "paradas_obra_id_fkey", on_delete: :cascade
    add_index :paradas, [:obra_id, :nombre], unique: true
  end
end
