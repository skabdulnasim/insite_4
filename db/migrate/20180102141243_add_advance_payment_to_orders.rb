class AddAdvancePaymentToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :advance_payment, :float, :default => 0
  end
end
