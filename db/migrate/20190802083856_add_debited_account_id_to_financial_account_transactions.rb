class AddDebitedAccountIdToFinancialAccountTransactions < ActiveRecord::Migration
  def change
    add_column :financial_account_transactions, :debited_acc_id, :integer
  end
end
