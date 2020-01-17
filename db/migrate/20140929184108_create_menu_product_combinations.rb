class CreateMenuProductCombinations < ActiveRecord::Migration
  def change
    create_table :menu_product_combinations do |t|
      t.integer :menu_product_id
      t.integer :combination_type_id
      t.integer :product_id
      t.float :price

      t.timestamps
    end
  end
end
