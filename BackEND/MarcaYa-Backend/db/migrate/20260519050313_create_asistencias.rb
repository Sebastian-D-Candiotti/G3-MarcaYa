class CreateAsistencias < ActiveRecord::Migration[8.1]
  def change
    create_table :asistencias do |t|
      t.integer :empleado_id
      t.integer :obra_id
      t.date :fecha
      t.datetime :hora_entrada
      t.datetime :hora_salida
      t.float :horas_trabajadas
      t.boolean :es_valida_gps

      t.timestamps
    end
  end
end
