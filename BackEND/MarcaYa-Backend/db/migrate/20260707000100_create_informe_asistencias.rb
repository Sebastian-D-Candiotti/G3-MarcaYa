class CreateInformeAsistencias < ActiveRecord::Migration[8.1]
  def change
    create_table :informe_asistencias do |t|
      t.references :empresa, null: false, foreign_key: true
      t.string :tipo_periodo, limit: 20, null: false
      t.date :fecha_inicio, null: false
      t.date :fecha_fin, null: false
      t.string :estado, limit: 20, null: false, default: "BORRADOR"
      t.datetime :fecha_generacion, null: false
      t.datetime :fecha_cierre
      t.references :generado_por, null: false, foreign_key: { to_table: :usuarios }
      t.integer :version, null: false, default: 1
      t.jsonb :snapshot, null: false, default: {}
      t.string :checksum, limit: 64, null: false

      t.timestamps
    end

    add_index :informe_asistencias, :tipo_periodo
    add_index :informe_asistencias, :estado
    add_index :informe_asistencias, :fecha_inicio
    add_index :informe_asistencias, :fecha_fin
    add_index :informe_asistencias,
              [:empresa_id, :tipo_periodo, :fecha_inicio, :fecha_fin],
              unique: true,
              where: "estado = 'CERRADO'",
              name: "idx_informe_asistencias_cerrado_unico"

    add_check_constraint :informe_asistencias,
                         "tipo_periodo IN ('DIARIO', 'SEMANAL', 'MENSUAL')",
                         name: "informe_asistencias_tipo_periodo_check"
    add_check_constraint :informe_asistencias,
                         "estado IN ('BORRADOR', 'CERRADO')",
                         name: "informe_asistencias_estado_check"
    add_check_constraint :informe_asistencias,
                         "fecha_fin >= fecha_inicio",
                         name: "informe_asistencias_rango_fechas_check"
  end
end
