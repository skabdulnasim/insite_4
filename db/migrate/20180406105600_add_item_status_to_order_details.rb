class AddItemStatusToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :item_status, :string
  end
end
