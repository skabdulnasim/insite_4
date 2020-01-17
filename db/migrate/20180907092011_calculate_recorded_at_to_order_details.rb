class CalculateRecordedAtToOrderDetails < ActiveRecord::Migration
  def up
  	_orders = Order.all
  	_orders.each do |order|
  		order.order_details.each do |od|
  			od.update_column(:recorded_at, order.recorded_at)
  			puts od.id
  		end	
  	end	
  end

  def down
  end
end
