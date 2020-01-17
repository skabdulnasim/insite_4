class AddRecordedAtToFinancialAccountTransactions < ActiveRecord::Migration
  def change
    add_column :financial_account_transactions, :recorded_at, :datetime
  end
end
