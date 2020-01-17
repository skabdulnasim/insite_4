class ChangePaxToIntegerInCustomerQueues < ActiveRecord::Migration
  def change
  	remove_column :customer_queues, :pax
  end
end
