class ModifyLoyaltyCardTransaction < ActiveRecord::Migration
  def change
    remove_column :loyalty_card_transactions, :transaction_type
    remove_column :loyalty_card_transactions, :points
    remove_column :loyalty_card_transactions, :points_after_transaction
    remove_column :loyalty_card_transactions, :equivalent_money
    remove_column :loyalty_card_transactions, :remarks
    remove_column :loyalty_card_transactions, :transaction_amount
  end
end
