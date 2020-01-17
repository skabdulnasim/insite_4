class UpdateDelivaryDateToOrderDetails < ActiveRecord::Migration
  def up
  	_orders = Order.all
  	_orders.each do |order|
  		order.order_details.each do |od|
  			od.update_column(:delivary_date, order.delivary_date)
  			puts od.id
  		end	
  	end	
  end

  def down
  end
end
