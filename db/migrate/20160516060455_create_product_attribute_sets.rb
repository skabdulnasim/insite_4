class CreateProductAttributeSets < ActiveRecord::Migration
  def change
    create_table :product_attribute_sets do |t|
      t.string :name
      t.boolean :is_default
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
