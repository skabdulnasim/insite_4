class AddBoxingIdToStockTransfers < ActiveRecord::Migration
  def change
    add_column :stock_transfers, :boxing_id, :integer
  end
end
