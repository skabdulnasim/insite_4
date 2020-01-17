class AddDeliveryChargesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_charges, :float
  end
end
