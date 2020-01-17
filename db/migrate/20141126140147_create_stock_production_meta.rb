class CreateStockProductionMeta < ActiveRecord::Migration
  def change
    create_table :stock_production_meta do |t|
      t.integer :kitchen_store_id
      t.integer :store_id
      t.integer :store_production_id
      t.integer :product_id
      t.float :production_quantity
      t.text :ingredients

      t.timestamps
    end
  end
end
