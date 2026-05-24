class CreateValoracions < ActiveRecord::Migration[8.1]
  def change
    create_table :valoracions do |t|
      t.integer :empleado_id
      t.integer :puntaje
      t.string :comentario
      t.date :fecha

      t.timestamps
    end
  end
end
