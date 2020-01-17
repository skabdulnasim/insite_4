class AddBillDataToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_total_without_tax, :float
    add_column :orders, :total_tax, :float
    add_column :orders, :total_discount, :float
    add_column :orders, :order_subtotal, :float
  end
end
