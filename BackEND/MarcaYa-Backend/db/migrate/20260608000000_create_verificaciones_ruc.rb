# frozen_string_literal: true

class CreateVerificacionesRuc < ActiveRecord::Migration[8.1]
  def change
    create_table :verificaciones_ruc do |t|
      t.string :ruc, null: false
      t.string :codigo, null: false
      t.datetime :expira_at, null: false

      t.timestamps
    end

    add_index :verificaciones_ruc, :ruc, unique: true
  end
end
