class RenameObraIdToEmpresaIdInSolicitudes < ActiveRecord::Migration[8.1]
  def up
    # 1. Execute SQL to copy accepted solicitudes data to asignaciones
    execute <<-SQL
      INSERT INTO asignaciones (empleado_id, obra_id, estado, created_at, updated_at)
      SELECT empleado_id, obra_id, 'activo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM solicitudes
      WHERE estado = 'aceptada'
    SQL

    # 2. Rename column obra_id to empresa_id in solicitudes
    rename_column :solicitudes, :obra_id, :empresa_id

    # 3. Add foreign key constraint from solicitudes.empresa_id to empresas.id
    add_foreign_key :solicitudes, :empresas, column: :empresa_id, name: "solicitudes_empresa_id_fkey"
  end

  def down
    # 1. Remove foreign key constraint
    remove_foreign_key :solicitudes, name: "solicitudes_empresa_id_fkey"

    # 2. Rename column empresa_id back to obra_id
    rename_column :solicitudes, :empresa_id, :obra_id

    # 3. Remove asignaciones that were created for accepted solicitudes
    execute <<-SQL
      DELETE FROM asignaciones
      WHERE estado = 'activo'
      AND (empleado_id, obra_id) IN (
        SELECT empleado_id, obra_id
        FROM solicitudes
        WHERE estado = 'aceptada'
      )
    SQL
  end
end
