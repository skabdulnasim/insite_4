class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.date :reservation_date
      t.integer :pax
      t.references :customer
      t.references :resource
      t.references :slot

      t.timestamps
    end
    add_index :reservations, :customer_id
    add_index :reservations, :resource_id
    add_index :reservations, :slot_id
  end
end
