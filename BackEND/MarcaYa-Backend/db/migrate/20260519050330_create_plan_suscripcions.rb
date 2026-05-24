class CreatePlanSuscripcions < ActiveRecord::Migration[8.1]
  def change
    create_table :plan_suscripcions do |t|
      t.string :nombre
      t.float :precio
      t.integer :limite_empleados

      t.timestamps
    end
  end
end
