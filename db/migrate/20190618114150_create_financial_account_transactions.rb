class CreateFinancialAccountTransactions < ActiveRecord::Migration
  def change
    create_table :financial_account_transactions do |t|
      t.float :amount
      t.string :transaction_type
      t.string :purpose
      t.string :remarks
      t.references :financial_account

      t.timestamps
    end
    add_index :financial_account_transactions, :financial_account_id
  end
end
