# frozen_string_literal: true

class AddOtpVerificadoToEmpresas < ActiveRecord::Migration[8.1]
  def change
    add_column :empresas, :otp_verificado, :boolean, default: false, null: false
  end
end
