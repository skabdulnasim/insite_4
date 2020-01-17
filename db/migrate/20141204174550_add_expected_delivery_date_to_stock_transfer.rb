class AddExpectedDeliveryDateToStockTransfer < ActiveRecord::Migration
  def change
    add_column :stock_transfers, :expected_delivery_date, :date
    rename_column :stock_transfers, :store_requisition_id, :store_requisition_log_id
  end
end
