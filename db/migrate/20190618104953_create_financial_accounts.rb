class CreateFinancialAccounts < ActiveRecord::Migration
  def change
    create_table :financial_accounts do |t|
      t.float :total_credit
      t.float :total_debit
      t.float :current_balance
      t.string :account_holder_type
      t.integer :account_holder_id

      t.timestamps
    end
  end
end
