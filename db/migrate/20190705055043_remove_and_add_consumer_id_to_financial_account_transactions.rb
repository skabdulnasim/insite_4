class RemoveAndAddConsumerIdToFinancialAccountTransactions < ActiveRecord::Migration
  def change
    remove_column :financial_accounts, :consumer_id
    add_column :financial_account_transactions, :consumer_id, :integer
  end
end