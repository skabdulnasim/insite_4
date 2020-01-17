class AddOwnCustomerIdToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :own_customer_id, :integer
  end
end
