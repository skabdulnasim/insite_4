class AddOrderSrNoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_sr_no, :text
  end
end
