class AddReturnItemCheckToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :is_returned, :boolean, default: false
  end
end
