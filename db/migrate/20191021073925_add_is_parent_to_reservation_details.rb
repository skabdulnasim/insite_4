class AddIsParentToReservationDetails < ActiveRecord::Migration
  def change
    add_column :reservation_details, :is_parent, :string
  end
end
