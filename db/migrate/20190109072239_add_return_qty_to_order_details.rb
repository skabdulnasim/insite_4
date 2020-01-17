class AddReturnQtyToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :return_qty, :float
  end
end
