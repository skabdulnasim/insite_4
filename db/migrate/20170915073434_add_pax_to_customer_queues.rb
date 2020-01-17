class AddPaxToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :pax, :string
  end
end
