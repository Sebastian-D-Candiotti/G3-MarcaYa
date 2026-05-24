class CreateObras < ActiveRecord::Migration[8.1]
  def change
    create_table :obras do |t|
      t.integer :empresa_id
      t.string :nombre
      t.string :descripcion_ubicacion
      t.float :radio_metros
      t.string :estado
      t.float :latitud
      t.float :longitud

      t.timestamps
    end
  end
end
