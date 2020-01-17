class AddProductDescToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :lot_desc, :text
  end
end
