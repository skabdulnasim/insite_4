class AddParcelDetailsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billed, :integer
    add_column :order_details, :parcel, :integer
    remove_column :order_details, :menu_product_name, :product_id
  end
end
