class AddTimeToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :start_time, :time
    add_column :reservations, :end_time, :time
  end
end
