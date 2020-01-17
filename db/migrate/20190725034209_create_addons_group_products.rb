class CreateAddonsGroupProducts < ActiveRecord::Migration
  def change
    create_table :addons_group_products do |t|
      t.integer :addons_group_id
      t.integer :product_id

      t.timestamps
    end
  end
end
