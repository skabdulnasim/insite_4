class CreateCashes < ActiveRecord::Migration
  def change
    create_table :cashes do |t|
      t.integer :denomination
      t.integer :tendered_amount
      t.integer :balance_return

      t.timestamps
    end
  end
end
