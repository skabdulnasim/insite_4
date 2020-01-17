class CreateProductMeta < ActiveRecord::Migration
  def change
    create_table :product_meta do |t|
      t.text :raw

      t.timestamps
    end
  end
end
