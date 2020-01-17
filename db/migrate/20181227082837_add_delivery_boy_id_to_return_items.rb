class AddDeliveryBoyIdToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :delivery_boy_id, :integer
  end
end
