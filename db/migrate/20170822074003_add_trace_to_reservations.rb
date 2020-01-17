class AddTraceToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :trace, :integer, :default => 0, :null => false
  end
end
