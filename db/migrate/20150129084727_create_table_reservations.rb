class CreateTableReservations < ActiveRecord::Migration
  def change
    create_table :table_reservations do |t|
      t.string :customer_name
      t.integer :contact_no
      t.date :reservation_date
      t.string :remarks
      t.integer :head_count
      t.time :from_time
      t.time :to_time
      t.text :status

      t.timestamps
    end
  end
end
