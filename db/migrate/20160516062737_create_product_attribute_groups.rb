class CreateProductAttributeGroups < ActiveRecord::Migration
  def change
    create_table :product_attribute_groups do |t|
      t.string :name
      t.belongs_to :product_attribute_set
      t.integer :position
      t.boolean :is_system_entity
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :product_attribute_groups, :product_attribute_set_id
  end
end
