class CreateProductSizeImages < ActiveRecord::Migration
  def change
    create_table :product_size_images do |t|
      t.integer :product_size_id

      t.timestamps
    end
  end
end
