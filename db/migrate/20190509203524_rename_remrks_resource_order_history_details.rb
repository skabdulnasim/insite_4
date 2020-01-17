class RenameRemrksResourceOrderHistoryDetails < ActiveRecord::Migration
  def up
  	rename_column :resource_order_history_details, :remrks, :remarks
  end
end
