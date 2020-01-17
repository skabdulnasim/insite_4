class AddUnitIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :unit_id, :integer
    add_index :reservations, :unit_id
  end
end
