class AddCustomerQueueIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_queue_id, :integer
  end
end
