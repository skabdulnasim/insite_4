class CreateWalletPayments < ActiveRecord::Migration
  def change
    create_table :wallet_payments do |t|
      t.float :amount
      t.string :card_number
      t.string :customer_phone
      t.string :wallet_name

      t.timestamps
    end
  end
end
