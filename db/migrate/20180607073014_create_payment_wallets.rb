class CreatePaymentWallets < ActiveRecord::Migration
  def change
    create_table :payment_wallets do |t|
      t.string :name

      t.timestamps
    end
  end
end
