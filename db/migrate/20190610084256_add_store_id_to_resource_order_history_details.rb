class AddStoreIdToResourceOrderHistoryDetails < ActiveRecord::Migration
  def change
    add_column :resource_order_history_details, :store_id, :integer
  end
end
