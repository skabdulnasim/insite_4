class RenameTableStatusesToOrderStatuses < ActiveRecord::Migration
  def change
    rename_table :statuses, :order_statuses
  end
end
