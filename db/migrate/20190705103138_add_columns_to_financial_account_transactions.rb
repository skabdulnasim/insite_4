class AddColumnsToFinancialAccountTransactions < ActiveRecord::Migration
  def change
    add_column :financial_account_transactions, :transaction_entity_type, :string
    add_column :financial_account_transactions, :transaction_entity_id, :integer
    add_column :financial_account_transactions, :fat_paymentmode_type, :string
    add_column :financial_account_transactions, :fat_paymentmode_id, :integer
  end
end