class AddFromDateToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :from_date, :timestamp
  end
end
