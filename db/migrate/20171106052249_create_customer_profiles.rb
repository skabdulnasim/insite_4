class CreateCustomerProfiles < ActiveRecord::Migration
  def change
    create_table :customer_profiles do |t|
      t.integer :customer_id
      t.text :address
      t.string :age
      t.string :anniversary
      t.string :contact_no
      t.string :customer_name
      t.string :dob
      t.string :firstname
      t.string :gender
      t.string :lastname

      t.timestamps
    end
  end
end
