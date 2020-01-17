class RemoveUnitIdFromDeliveryAddresses < ActiveRecord::Migration
  def up
    remove_column :delivery_addresses, :unit_id
  end

  def down
    add_column :delivery_addresses, :unit_id, :integer
  end
end
