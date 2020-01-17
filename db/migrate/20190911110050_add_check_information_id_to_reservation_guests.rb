class AddCheckInformationIdToReservationGuests < ActiveRecord::Migration
  def change
    add_column :reservation_guests, :check_information_id, :integer
  end
end
