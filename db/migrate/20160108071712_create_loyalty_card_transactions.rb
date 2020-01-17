class CreateLoyaltyCardTransactions < ActiveRecord::Migration
  def change
    create_table :loyalty_card_transactions do |t|
      t.references :loyalty_card
      t.string :transaction_type
      t.references :loyalty_transaction, polymorphic: true
      t.decimal :points
      t.decimal :points_after_transaction
      t.decimal :equivalent_money
      t.text :remarks

      t.timestamps
    end
    add_index :loyalty_card_transactions, :loyalty_card_id
    add_index :loyalty_card_transactions, :loyalty_transaction_id
  end
end
