class CreateFinalcialAccountPayments < ActiveRecord::Migration
  def change
    create_table :finalcial_account_payments do |t|
      t.integer :finalcial_account_id
      t.float :amount
      t.string :account_no
      t.integer :customer_id

      t.timestamps
    end
  end
end
