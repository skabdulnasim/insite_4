class AddStoreIdToStockProductionMetas < ActiveRecord::Migration
  def up
    add_column :stock_production_meta, :store_id, :integer
  end

  def down
    remove_column :stock_production_meta, :store_id
  end
end
