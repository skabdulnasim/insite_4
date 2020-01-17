class AddRequisitionCodeToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :requisition_code, :text
  end
end
