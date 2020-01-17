class AddStockIdToStockUpdates < ActiveRecord::Migration
  def change
    add_column :stock_updates, :stock_ref_id, :integer
  end
end
