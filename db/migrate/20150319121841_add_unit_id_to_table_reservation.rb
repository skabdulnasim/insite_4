class AddUnitIdToTableReservation < ActiveRecord::Migration
  def change
    add_column :table_reservations, :unit_id, :integer
  end
end
