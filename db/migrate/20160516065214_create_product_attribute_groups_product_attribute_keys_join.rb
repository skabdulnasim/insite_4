class CreateProductAttributeGroupsProductAttributeKeysJoin < ActiveRecord::Migration
  def up
    create_table :product_attribute_groups_product_attribute_keys, :id => false do |t|
      t.integer "product_attribute_group_id"
      t.integer "product_attribute_key_id"
    end
    add_index :product_attribute_groups_product_attribute_keys, :product_attribute_group_id, :name => "product_attribute_group_ref"
    add_index :product_attribute_groups_product_attribute_keys, :product_attribute_key_id, :name => "product_attribute_key_ref"
  end

  def down
    drop_table :product_attribute_groups_product_attribute_keys
  end
end
