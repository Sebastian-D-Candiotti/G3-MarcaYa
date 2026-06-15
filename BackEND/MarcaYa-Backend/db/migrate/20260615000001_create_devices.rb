# frozen_string_literal: true

class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: { to_table: :usuarios, on_delete: :cascade }
      t.string :fcm_token, null: false
      t.string :platform, limit: 20, null: false
      t.timestamps
    end

    add_index :devices, :fcm_token, unique: true
  end
end
