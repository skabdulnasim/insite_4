class CalculateDeliveryCharges < ActiveRecord::Migration
  def up
  	Order.update_all("delivery_charges=0")
  	Bill.update_all("delivery_charges=0")
  end
end
