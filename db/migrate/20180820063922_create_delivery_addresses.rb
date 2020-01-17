class CreateDeliveryAddresses < ActiveRecord::Migration
  def change
    create_table :delivery_addresses do |t|
      t.text :pincode
      t.text :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
