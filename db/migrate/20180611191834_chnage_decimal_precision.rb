class ChnageDecimalPrecision < ActiveRecord::Migration
  def up
    change_column :wallets, :current_balance, :decimal, :precision=>12, :scale=>2 
    change_column :wallets, :total_credit, :decimal, :precision=>12, :scale=>2 
    change_column :wallets, :total_debit, :decimal, :precision=>12, :scale=>2 
    change_column :wallet_transactions, :amount, :decimal, :precision=>12, :scale=>2 
  end

  def down
  end
end
