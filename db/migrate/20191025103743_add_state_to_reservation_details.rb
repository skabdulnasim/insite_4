class AddStateToReservationDetails < ActiveRecord::Migration
  def change
    add_column :reservation_details, :state, :string
  end
end
