class AddMobileNoReservations < ActiveRecord::Migration
  def change
  	add_column :reservations, :customer_mobile, :text
  end
end
