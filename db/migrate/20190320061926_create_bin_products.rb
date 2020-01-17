class CreateBinProducts < ActiveRecord::Migration
  def change
    create_table :bin_products do |t|
      t.integer :bin_id
      t.integer :product_id
      t.string :bin_unique_id
      t.string :product_sku
      t.integer :product_quantity

      t.timestamps
    end
  end
end
