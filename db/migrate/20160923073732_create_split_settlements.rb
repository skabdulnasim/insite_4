class CreateSplitSettlements < ActiveRecord::Migration
  def change
    create_table :split_settlements do |t|
      t.integer :bill_split_id
      t.integer :bill_id
      t.float :bill_split_ammount
      t.string :status
      t.string :device_id
      t.integer :client_id
      t.string :client_type
      t.datetime :recorded_at
      t.timestamps
    end
  end
end
