class CreateLoyaltyDebitTransactions < ActiveRecord::Migration
  def change
    create_table :loyalty_debit_transactions do |t|
      t.references :loyalty_card
      t.references :loyalty_debit_transaction
      t.string :loyalty_debit_transaction_type

      t.timestamps
    end
    add_index :loyalty_debit_transactions, :loyalty_card_id
    add_index :loyalty_debit_transactions, :loyalty_debit_transaction_id, :name=>"loyalty_debit_transaction_ref"
  end
end
