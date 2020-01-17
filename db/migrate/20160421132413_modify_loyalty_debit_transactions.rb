class ModifyLoyaltyDebitTransactions < ActiveRecord::Migration
  def up
    rename_column :loyalty_debit_transactions, :loyalty_debit_transaction_id, :loyalty_debit_id
    rename_column :loyalty_debit_transactions, :loyalty_debit_transaction_type, :loyalty_debit_type
    remove_index  :loyalty_debit_transactions, :name=>"loyalty_debit_transaction_ref"
    add_index :loyalty_debit_transactions, :loyalty_debit_id
  end

  def down
  end
  
end
