class AddBillDestinationIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :bill_destination_id, :integer
    add_column :bills, :lite_device_id, :string
  end
end
