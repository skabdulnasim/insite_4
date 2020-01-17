class AddSectionIdToTableReservation < ActiveRecord::Migration
  def change
    add_column :table_reservations, :section_id, :integer
  end
end
