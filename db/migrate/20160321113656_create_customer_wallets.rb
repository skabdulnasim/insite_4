class CreateCustomerWallets < ActiveRecord::Migration
  def change
    create_table :customer_wallets do |t|
      t.integer :customer_id
      t.float :credited_amount
      t.float :debited_amount
      t.integer :return_item_id
      t.float :available_amount
      t.date :expiry_date

      t.timestamps
    end
  end
end
