class AddRservationIdToOrders < ActiveRecord::Migration
  def change
  	unless column_exists? :orders, :reservation_id
    	add_column :orders, :reservation_id, :integer
    end	
  end
end
