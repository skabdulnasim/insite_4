class AddDefaultValueToReservations < ActiveRecord::Migration
  def up
  	change_column :reservations, :trash, :integer, default: 0
  end
end
