class AddToDateToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :to_date, :timestamp
  end
end
