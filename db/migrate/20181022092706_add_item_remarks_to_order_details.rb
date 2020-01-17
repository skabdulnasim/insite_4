class AddItemRemarksToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :item_remarks, :text
  end
end
