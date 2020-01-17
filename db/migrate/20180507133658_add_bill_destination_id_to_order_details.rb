class AddBillDestinationIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :bill_destination_id, :integer
  end
end
