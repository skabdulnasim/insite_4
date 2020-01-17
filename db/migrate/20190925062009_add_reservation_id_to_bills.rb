class AddReservationIdToBills < ActiveRecord::Migration
  def change
  	unless column_exists? :bills, :reservation_id
    	add_column :bills, :reservation_id, :integer
    end	
  end
end
