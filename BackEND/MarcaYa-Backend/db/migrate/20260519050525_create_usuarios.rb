class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nombre
      t.string :correo
      t.string :clave_hash
      t.string :rol

      t.timestamps
    end
  end
end
