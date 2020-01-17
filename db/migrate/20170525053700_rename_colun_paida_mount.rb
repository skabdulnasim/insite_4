class RenameColunPaidaMount < ActiveRecord::Migration
  def up
  	rename_column :stock_purchases, :paida_mount, :paid_amount
  end

  def down
  end
end
