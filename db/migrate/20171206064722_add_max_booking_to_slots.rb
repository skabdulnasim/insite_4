class AddMaxBookingToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :max_booking, :integer
  end
end
