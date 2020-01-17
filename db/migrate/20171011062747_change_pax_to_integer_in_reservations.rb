class ChangePaxToIntegerInReservations < ActiveRecord::Migration
  def change
  	change_column :reservations, :pax, :integer
  end
end
