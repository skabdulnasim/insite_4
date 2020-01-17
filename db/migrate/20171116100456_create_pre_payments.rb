class CreatePrePayments < ActiveRecord::Migration
  def change
    create_table :pre_payments do |t|
      t.string :pre_paymentmode_type
      t.integer :pre_paymentmode_id
      t.integer :preauth_id

      t.timestamps
    end
  end
end
