class RemoveFromDateTimeAndToDateTimeFromCustomerQueues < ActiveRecord::Migration
  def up
    remove_column :customer_queues, :from_date_time
    remove_column :customer_queues, :to_date_time
  end
end
