class AddItemPreferenceToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :item_preference, :text
  end
end
