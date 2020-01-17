class AddDeliveryStatusToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :delivery_status, :integer
  end
end
