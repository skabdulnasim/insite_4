class CreateMoneyRefunds < ActiveRecord::Migration
  def change
    create_table :money_refunds do |t|
      t.integer :customer_id
      t.integer :order_id
      t.string :paymentmode
      t.float :refund_amount
      t.string :account_no
      t.string :ifsc_code

      t.timestamps
    end
  end
end
