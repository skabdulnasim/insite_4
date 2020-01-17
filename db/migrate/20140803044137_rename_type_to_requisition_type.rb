class RenameTypeToRequisitionType < ActiveRecord::Migration
  def up
    rename_column :store_requisitions, :type, :requisition_type
  end

  def down
    rename_column :store_requisitions, :requisition_type, :type
  end
end
