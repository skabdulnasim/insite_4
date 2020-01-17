class CreateProductAttributeKeys < ActiveRecord::Migration
  def change
    create_table :product_attribute_keys do |t|
      t.string :attribute_code
      t.string :label
      t.string :input_type
      t.text :default_value
      t.boolean :is_unique
      t.boolean :is_required
      t.boolean :is_comparable
      t.boolean :is_sortable
      t.boolean :is_system_entity
      t.boolean :is_for_variable_product
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
