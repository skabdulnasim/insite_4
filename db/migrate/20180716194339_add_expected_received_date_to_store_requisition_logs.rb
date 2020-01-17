class AddExpectedReceivedDateToStoreRequisitionLogs < ActiveRecord::Migration
  def change
    add_column :store_requisition_logs, :expected_received_date, :datetime
  end
end
