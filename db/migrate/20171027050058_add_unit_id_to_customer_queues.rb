class AddUnitIdToCustomerQueues < ActiveRecord::Migration
  def change
    add_column :customer_queues, :unit_id, :integer
  end
end
