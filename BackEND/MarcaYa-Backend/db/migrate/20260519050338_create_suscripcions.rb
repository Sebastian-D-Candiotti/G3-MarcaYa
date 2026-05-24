class CreateSuscripcions < ActiveRecord::Migration[8.1]
  def change
    create_table :suscripcions do |t|
      t.integer :empresa_id
      t.integer :plan_suscripcion_id
      t.date :fecha_inicio
      t.date :fecha_fin
      t.string :estado

      t.timestamps
    end
  end
end
