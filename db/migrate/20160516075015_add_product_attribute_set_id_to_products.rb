class AddProductAttributeSetIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_attribute_set_id, :integer
    add_column :products, :deleted_at, :datetime
    add_index :products, :product_attribute_set_id
  end
end
