class RenameStoreProductionIdToStockProductionId < ActiveRecord::Migration
  def up
    rename_column :stock_production_meta, :store_production_id, :stock_production_id
  end

  def down
  end
end
