class AddDeliverableBillByBillSales < ActiveRecord::Migration
  def up
  	add_column :bill_by_bill_sales, :deliverable, :string
  end
end
