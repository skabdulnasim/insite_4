class CreatePaypalPayments < ActiveRecord::Migration
  def change
    create_table :paypal_payments do |t|
      t.float :amount
      t.string :transaction_id
      t.datetime :recorded_at
      t.timestamps
    end
  end
end
