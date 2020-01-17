class CreateUnitProducts < ActiveRecord::Migration
  def change
    unless table_exists?("unit_products")
      create_table :unit_products do |t|
        t.integer :product_id
        t.integer :unit_id
        t.integer :input_tax_group_id

        t.timestamps
      end
    end
  end
end
