class AddColorIdAndSizeIdToStoreRequisitionMetum < ActiveRecord::Migration
  def change
    add_column :store_requisition_meta, :color_id, :integer
    add_column :store_requisition_meta, :size_id, :integer
  end
end
