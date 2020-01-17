class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :type
      t.integer :unit_id
      t.text :address
      t.string :pincode
      t.string :contact_number
      t.string :store_image

      t.timestamps
    end
  end
end
