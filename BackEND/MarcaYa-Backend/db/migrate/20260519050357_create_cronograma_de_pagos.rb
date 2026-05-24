class CreateCronogramaDePagos < ActiveRecord::Migration[8.1]
  def change
    create_table :cronograma_de_pagos do |t|
      t.integer :empresa_id
      t.date :fecha_pago
      t.float :monto_total

      t.timestamps
    end
  end
end
