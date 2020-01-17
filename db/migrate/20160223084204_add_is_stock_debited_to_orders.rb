class AddIsStockDebitedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_stock_debited, :boolean, :default => false
    Order.update_all(is_stock_debited: true)
  end
end
