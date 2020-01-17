class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :customer_id
      t.string :place
      t.string :city
      t.string :state
      t.string :locality
      t.string :landmark
      t.string :pincode
      t.string :receiver_name
      t.string :receiver_first_name
      t.string :receiver_last_name
      t.string :latitude
      t.string :longitude
      t.text :delivery_address
      t.string :contact_no

      t.timestamps
    end
  end
end
