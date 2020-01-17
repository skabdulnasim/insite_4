class CreateCustomerWalletPayments < ActiveRecord::Migration
  def change
    create_table :customer_wallet_payments do |t|
      t.integer :wallet_id
      t.integer :customer_id
      t.float :amount

      t.timestamps
    end
  end
end
