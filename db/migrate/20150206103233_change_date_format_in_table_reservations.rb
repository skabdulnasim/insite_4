class ChangeDateFormatInTableReservations < ActiveRecord::Migration
  def up
    change_column :table_reservations, :reservation_date, :datetime
  end

  def down
    change_column :table_reservations, :reservation_date, :date
  end
end
