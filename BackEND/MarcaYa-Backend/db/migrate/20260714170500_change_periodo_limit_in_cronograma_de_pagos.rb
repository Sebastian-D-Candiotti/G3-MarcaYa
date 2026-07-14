class ChangePeriodoLimitInCronogramaDePagos < ActiveRecord::Migration[8.1]
  def change
    change_column :cronograma_de_pagos, :periodo, :string, limit: 30
  end
end
