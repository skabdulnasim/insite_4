class AddDeviceIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :device_id, :string
  end
end
