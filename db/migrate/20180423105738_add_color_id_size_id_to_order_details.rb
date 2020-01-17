class AddColorIdSizeIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :color_id, :integer
    add_column :order_details, :size_id, :integer
  end
end
