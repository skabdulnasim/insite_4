class AddAccountTypeToFinalcialAccounts < ActiveRecord::Migration
  def change
    add_column :financial_accounts, :account_type, :string
  end
end
