class AddStoreRequisitionIdToStoreTransfer < ActiveRecord::Migration
  def change
    add_column :stock_transfers, :store_requisition_id, :integer
    add_column :stores, :store_priority, :string
    remove_column :stock_transfers, :vendor_id
  end
end
