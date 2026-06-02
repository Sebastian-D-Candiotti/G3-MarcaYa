# frozen_string_literal: true

class CreateRegistroAsistencias < ActiveRecord::Migration[8.1]
  def change
    create_table :registro_asistencias do |t|
      t.references :empleado, null: false, foreign_key: { on_delete: :restrict }
      t.references :parada, null: false, foreign_key: { on_delete: :restrict }
      t.string :tipo_marcacion, limit: 10, null: false
      t.datetime :fecha_hora, null: false
      t.float :latitud_registrada, null: false
      t.float :longitud_registrada, null: false
      t.boolean :valida_gps, null: false, default: true
      t.integer :duracion_jornada
      t.string :observaciones
      t.timestamps
    end

    add_index :registro_asistencias, :tipo_marcacion
    add_index :registro_asistencias, :fecha_hora
  end
end
