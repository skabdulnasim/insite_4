class CreatePrePaypalPayments < ActiveRecord::Migration
  def change
    create_table :pre_paypal_payments do |t|
      t.integer :transaction_id
      t.float :amount

      t.timestamps
    end
  end
end
