class ChangeSecondaryStoreIdTypeInStockTransfers < ActiveRecord::Migration
  def up
    change_column :stock_transfers, :secondary_store_id, 'integer USING CAST(secondary_store_id AS integer)'
  end

  def down
  end
end
