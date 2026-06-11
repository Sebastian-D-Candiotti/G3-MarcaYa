class AddEmailVerificationToUsuarios < ActiveRecord::Migration[8.1]
  def change
    add_column :usuarios, :estado_verificacion, :string, limit: 30, null: false, default: "ACTIVO"
    add_column :usuarios, :codigo_verificacion_digest, :string, limit: 255
    add_column :usuarios, :codigo_verificacion_expira_en, :datetime
    add_column :usuarios, :verificado_en, :datetime

    add_index :usuarios, :estado_verificacion
  end
end
