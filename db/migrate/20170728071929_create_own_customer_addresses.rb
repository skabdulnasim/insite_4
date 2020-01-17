class CreateOwnCustomerAddresses < ActiveRecord::Migration
  def change
    create_table :own_customer_addresses do |t|
      t.string :contact_no
      t.string :pincode
      t.string :landmark
      t.string :city
      t.string :state
      t.string :latitude
      t.string :longitude
      t.integer :own_customer_id
      t.timestamps
    end
  end
end
