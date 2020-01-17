class AddUnitIdToDeliveryAddresses < ActiveRecord::Migration
  def change
    add_column :delivery_addresses, :unit_id, :integer
  end
end
