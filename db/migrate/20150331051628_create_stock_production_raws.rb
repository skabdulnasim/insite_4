class CreateStockProductionRaws < ActiveRecord::Migration
  def change
    create_table :stock_production_raws do |t|
      t.integer :stock_production_meta_id
      t.integer :target_product_id
      t.integer :product_id
      t.integer :store_id
      t.float :quantity

      t.timestamps
    end
  end
end
