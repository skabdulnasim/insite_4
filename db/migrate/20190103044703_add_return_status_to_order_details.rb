class AddReturnStatusToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :is_refund, :string
    add_column :orders, :is_refund, :string
  end
end
