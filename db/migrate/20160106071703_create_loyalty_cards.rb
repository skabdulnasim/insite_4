class CreateLoyaltyCards < ActiveRecord::Migration
  def change
    create_table :loyalty_cards do |t|
      t.string :card_serial
      t.string :name_on_card
      t.integer :customer_id
      t.string :card_type
      t.string :card_class
      t.integer :points
      t.float :equivalent_money
      t.date :valid_from
      t.date :valid_till
      t.string :status

      t.timestamps
    end
  end
end
