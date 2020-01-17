class ChangeDateFormatInPurchaseOrders < ActiveRecord::Migration
  def up
  	change_column :purchase_orders, :valid_from, :datetime
  	change_column :purchase_orders, :valid_till, :datetime
  end

  def down
  	change_column :purchase_orders, :valid_from, :date
  	change_column :purchase_orders, :valid_till, :date
  end
end
