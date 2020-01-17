class CreateDeliveryAddressesUnits < ActiveRecord::Migration
  def change
    create_table :delivery_addresses_units do |t|
      t.integer :unit_id
      t.integer :delivery_address_id

      t.timestamps
    end
  end
end
