class AddDeviceIdConsumerTypeToFinancialAccountTransactions < ActiveRecord::Migration
  def change
    add_column :financial_account_transactions, :device_id, :string
    add_column :financial_account_transactions, :consumer_type, :string
  end
end
