class CreateLoyaltyPurchases < ActiveRecord::Migration
  def change
    create_table :loyalty_purchases do |t|
      t.references :loyalty_card
      t.decimal :point_purchase
      t.decimal :purchase_cost
      t.string :purchase_type

      t.timestamps
    end
    add_index :loyalty_purchases, :loyalty_card_id
  end
end
