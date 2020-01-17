class DeleteRequisitionTypeToStoreRequisitions < ActiveRecord::Migration
  def up
    remove_column :store_requisitions, :requisition_type
  end
end
