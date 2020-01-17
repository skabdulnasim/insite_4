class AddSettlementIdToSplitSettlements < ActiveRecord::Migration
  def change
    add_column :split_settlements, :settlement_id, :integer
  end
end
