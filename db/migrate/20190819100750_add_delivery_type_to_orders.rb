class AddDeliveryTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_type, :string
  end
end
