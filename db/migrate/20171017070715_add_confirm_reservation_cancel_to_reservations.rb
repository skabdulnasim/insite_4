class AddConfirmReservationCancelToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :confirm_reservation_cancel, :integer
  end
end
