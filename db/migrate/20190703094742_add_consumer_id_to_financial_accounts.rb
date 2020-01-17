class AddConsumerIdToFinancialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :consumer_id, :integer
  end
end
