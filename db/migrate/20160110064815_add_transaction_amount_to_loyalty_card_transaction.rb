class AddTransactionAmountToLoyaltyCardTransaction < ActiveRecord::Migration
  def change
    add_column :loyalty_card_transactions, :transaction_amount, :decimal
  end
end
