class ChangeProductAttributeGroupsProductAttributeKeysToProductAttributeGroupsKeys < ActiveRecord::Migration
  def change
  	rename_table :product_attribute_groups_product_attribute_keys, :product_attribute_groups_keys
  end
end
