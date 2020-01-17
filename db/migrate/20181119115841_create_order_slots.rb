class CreateOrderSlots < ActiveRecord::Migration
  def change
    create_table :order_slots do |t|
      t.integer :order_id
      t.integer :slot_id
      t.date :delivery_date

      t.timestamps
    end
  end
end
