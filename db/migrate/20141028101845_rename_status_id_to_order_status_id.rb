class RenameStatusIdToOrderStatusId < ActiveRecord::Migration
  def up
    rename_column :orders, :status_id, :order_status_id
  end

  def down
    rename_column :orders, :order_status_id, :status_id
  end
end
