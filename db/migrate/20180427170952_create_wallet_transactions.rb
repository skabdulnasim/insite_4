class CreateWalletTransactions < ActiveRecord::Migration
  def change
    create_table :wallet_transactions do |t|
      t.decimal :amount
      t.string :payment_type
      t.string :purpose
      t.string :remarks
      t.references :wallet

      t.timestamps
    end
    add_index :wallet_transactions, :wallet_id
  end
end
