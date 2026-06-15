# frozen_string_literal: true

class AddClienteMarcacionIdToRegistroAsistencias < ActiveRecord::Migration[8.1]
  def change
    add_column :registro_asistencias, :cliente_marcacion_id, :string, limit: 80
    add_index :registro_asistencias,
              :cliente_marcacion_id,
              unique: true,
              where: "cliente_marcacion_id IS NOT NULL"
  end
end
