class AddPaxIntegerToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :pax, :integer
  end
end
