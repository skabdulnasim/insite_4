class AddDeliveryModeAndMaxOrderQtyToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :delivery_mode, :string
    add_column :menu_products, :max_order_qty, :float
  end
end
