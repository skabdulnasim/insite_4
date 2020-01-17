class AddSourceToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :source, :string
  end
end
