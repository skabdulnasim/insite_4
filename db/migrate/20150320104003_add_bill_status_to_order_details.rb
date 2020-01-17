class AddBillStatusToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :bill_status, :string
  end
end
