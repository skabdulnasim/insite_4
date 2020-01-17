class AddDefaultValueToCustomerQues < ActiveRecord::Migration
  def up
  	change_column :customer_queues, :trash, :integer, default: 0
  	change_column :customer_queues, :is_reserved, :integer, default: 0
	end
end
