class CreateSettlements < ActiveRecord::Migration
  def change
    create_table :settlements do |t|
      t.integer :bill_id
      t.integer :bill_amount
      t.integer :tips
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
