class CreateProductAttributeOptions < ActiveRecord::Migration
  def change
    create_table :product_attribute_options do |t|
      t.belongs_to :product_attribute_key
      t.string :value
      t.string :label
      t.integer :position
      t.boolean :is_default
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :product_attribute_options, :product_attribute_key_id
  end
end
