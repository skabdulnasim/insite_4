class RemoveColoumColorIdFromOrderDetails < ActiveRecord::Migration
  def change
  	remove_column :order_details, :size_id
  	remove_column :order_details, :color_id
  	add_column :order_details, :color_name, :string
  	add_column :order_details, :size_name, :string
  end
end
