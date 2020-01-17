class AddRequisitionDetailsToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :requisition_details, :text
  end
end
