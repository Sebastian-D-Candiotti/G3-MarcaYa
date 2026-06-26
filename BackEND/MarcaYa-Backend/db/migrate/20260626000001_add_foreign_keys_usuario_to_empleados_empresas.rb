# frozen_string_literal: true

class AddForeignKeysUsuarioToEmpleadosEmpresas < ActiveRecord::Migration[8.1]
  def change
    # Empleados → Usuarios
    add_foreign_key :empleados, :usuarios, name: "empleados_usuario_id_fkey", on_delete: :cascade

    # Empresas → Usuarios
    add_foreign_key :empresas, :usuarios, name: "empresas_usuario_id_fkey", on_delete: :cascade
  end
end
