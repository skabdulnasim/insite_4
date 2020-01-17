class CreateTableReservationMeta < ActiveRecord::Migration
  def change
    create_table :table_reservation_meta do |t|
      t.integer :table_reservation_id
      t.integer :table_id
      t.time :timeslot
      t.date :date

      t.timestamps
    end
  end
end
