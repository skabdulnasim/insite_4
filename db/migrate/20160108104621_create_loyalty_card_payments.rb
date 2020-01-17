class CreateLoyaltyCardPayments < ActiveRecord::Migration
  def change
    create_table :loyalty_card_payments do |t|
      t.references :loyalty_card
      t.string :card_serial
      t.string :name_on_card
      t.decimal :amount
      t.decimal :points_used

      t.timestamps
    end
    add_index :loyalty_card_payments, :loyalty_card_id
  end
end
