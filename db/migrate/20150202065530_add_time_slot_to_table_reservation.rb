class AddTimeSlotToTableReservation < ActiveRecord::Migration
  def change
    add_column :table_reservations, :timeslot, :time
  end
end
