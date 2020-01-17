class AddSplitSettlementIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :split_settlement_id, :integer
  end
end
