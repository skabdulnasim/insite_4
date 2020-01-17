class CreateVendorProducts < ActiveRecord::Migration
  def change
    create_table :vendor_products do |t|
      t.integer :vendor_id
      t.integer :product_id
      t.float :price

      t.timestamps
    end
  end
end
