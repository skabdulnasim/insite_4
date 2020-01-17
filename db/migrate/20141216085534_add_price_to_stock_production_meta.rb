class AddPriceToStockProductionMeta < ActiveRecord::Migration
  def change
    add_column :stock_production_meta, :price, :float
    remove_column :stock_production_meta, :kitchen_store_id
    remove_column :stock_production_meta, :store_id
  end
end
