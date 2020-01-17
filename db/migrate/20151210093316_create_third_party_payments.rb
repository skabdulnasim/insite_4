class CreateThirdPartyPayments < ActiveRecord::Migration
  def change
    create_table :third_party_payments do |t|
      t.integer :third_party_payment_option_id
      t.string :third_party_payment_option_name
      t.float :amount

      t.timestamps
    end
  end
end
