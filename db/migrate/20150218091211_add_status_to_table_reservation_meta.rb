class AddStatusToTableReservationMeta < ActiveRecord::Migration
  def change
    add_column :table_reservation_meta, :status, :integer
  end
end
