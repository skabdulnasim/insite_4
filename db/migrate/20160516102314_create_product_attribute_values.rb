class CreateProductAttributeValues < ActiveRecord::Migration
  def change
    create_table :product_attribute_values do |t|
      t.belongs_to :product
      t.belongs_to :product_attribute_key
      t.string :label
      t.string :code
      t.text :value

      t.timestamps
    end
    add_index :product_attribute_values, :product_id
    add_index :product_attribute_values, :product_attribute_key_id
  end
end
