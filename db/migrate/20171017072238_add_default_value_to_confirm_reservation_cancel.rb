class AddDefaultValueToConfirmReservationCancel < ActiveRecord::Migration
  def up
  	change_column :reservations, :confirm_reservation_cancel, :integer, default: 0
  end
end
