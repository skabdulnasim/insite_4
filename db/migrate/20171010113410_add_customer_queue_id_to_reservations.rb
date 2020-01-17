class AddCustomerQueueIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :customer_queue_id, :integer
  end
end
