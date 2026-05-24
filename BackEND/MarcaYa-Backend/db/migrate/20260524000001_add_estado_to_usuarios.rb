class AddEstadoToUsuarios < ActiveRecord::Migration[8.1]
  def change
    add_column :usuarios, :estado, :string, default: 'activo'
  end
end
