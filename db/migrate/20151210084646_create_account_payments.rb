class CreateAccountPayments < ActiveRecord::Migration
  def change
    create_table :account_payments do |t|
      t.integer :user_id
      t.integer :user_name
      t.float :amount
      t.timestamps
    end
  end
end
