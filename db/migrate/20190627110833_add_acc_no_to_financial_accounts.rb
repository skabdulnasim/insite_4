class AddAccNoToFinancialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :acc_no, :string
  end
end
