class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :pays, :creadit_amount, :credit_amount
  end
end
